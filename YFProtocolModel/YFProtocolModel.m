//
//  YFProtocolModel.m
//  YFProtocolModel
//
//  Created by laizw on 2018/2/6.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import "YFProtocolModel.h"
#import "YFProtocolInfo.h"
#import <objc/runtime.h>

#pragma mark - Defines
static int const kIntent = 4;

YFProtocolRegisterStruct(CGRect)
YFProtocolRegisterStruct(CGSize)
YFProtocolRegisterStruct(CGPoint)
YFProtocolRegisterStruct(NSRange)
YFProtocolRegisterStruct(UIOffset)
YFProtocolRegisterStruct(CGVector)
YFProtocolRegisterStruct(UIEdgeInsets)
YFProtocolRegisterStruct(CGAffineTransform)


#pragma mark - YFProtocolModelDebug
@protocol YFProtocolModelDebug
- (NSString *)descriptionWithLevel:(int)level;
@end

@interface NSDictionary (YFProtocolModelDeug) <YFProtocolModelDebug>
@end

@interface NSArray (YFProtocolModelDeug) <YFProtocolModelDebug>
@end


#pragma mark - YFProtocolModel Interface
@interface YFProtocolModel : NSProxy <YFProtocolModel>
@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, strong) YFProtocolInfo *protocolInfo;
@property (nonatomic, strong) NSMutableDictionary *backend;

- (id)initWithProtocol:(Protocol *)protocol json:(NSDictionary *)json;
@end

@implementation YFProtocolModel

- (id)initWithProtocol:(Protocol *)protocol json:(NSDictionary *)json {
    self.protocol = protocol;
    self.protocolInfo = [YFProtocolInfo infoWithProtocol:protocol];
    self.backend = json ? [self buildEditableContainer:json] : @{}.mutableCopy;
    [self processTransformer];
    return self;
}

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"<%@ %p> \n", self.protocolInfo.name, self];
    [desc appendString:[self.backend descriptionWithLevel:0]];
    return desc;
}


#pragma mark - Process
- (id)buildEditableContainer:(id)json {
    // 非容器
    if (![json conformsToProtocol:@protocol(NSFastEnumeration)]) {
        return json;
    }
    // 字典类型
    else if ([json isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [json mutableCopy];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id newObj = [self buildEditableContainer:obj];
            [dict setObject:newObj forKey:key];
        }];
        return dict;
    }
    // mutable 集合类型
    else if ([json conformsToProtocol:@protocol(NSMutableCopying)]) {
        __typeof(json) container = [json mutableCopy];
        for (int i = 0; i < [json count]; i++) {
            id newObj = [self buildEditableContainer:json[i]];
            if (newObj) container[i] = newObj;
        }
        return container;
    }
    return json;
}

- (void)processTransformer {

    Class<YFProtocolModel> transformer = NSClassFromString([NSString stringWithFormat:@"__YFTransformer_%@", self.protocolInfo.name]);
    
    NSDictionary *keyMapperDict;
    if ([transformer respondsToSelector:@selector(modelPropertyKeyMapper)]) {
        keyMapperDict = [transformer modelPropertyKeyMapper];
    }
    
    NSDictionary *containerMapperDict;
    if ([transformer respondsToSelector:@selector(modelContainerPropertyGenericProtocol)]) {
        containerMapperDict = [transformer modelContainerPropertyGenericProtocol];
    }
    
    [self.protocolInfo.properties enumerateObjectsUsingBlock:^(YFPropertyInfo *obj, NSUInteger idx, BOOL *stop) {
        // key Mapper
        if (keyMapperDict && keyMapperDict[obj.name]) {
            id mapper = keyMapperDict[obj.name];
            if ([mapper isKindOfClass:[NSString class]]) {
                if ([mapper length]) {
                    obj.key = mapper;
                }
            } else if ([mapper isKindOfClass:[NSArray class]]) {
                [(NSArray *)mapper enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                    if ([self.backend valueForKeyPath:key]) {
                        obj.key = key;
                        *stop = YES;
                    }
                }];
            }
        }
        
        // Nested
        if (obj.flag & YFPropertyFlagProtocolType) {
            Protocol *protocol = NSProtocolFromString(obj.type);
            if (protocol) {
                NSDictionary *subJson = [self.backend valueForKey:obj.key];
                YFProtocolModel *model = YFProtocolModelCreate(protocol, subJson);
                [self.backend setValue:model forKey:obj.key];
            }
        }
        
        // Container
        if (containerMapperDict && containerMapperDict[obj.name]) {
            Protocol *protocol;
            id generic = containerMapperDict[obj.name];
            if ([generic isKindOfClass:NSClassFromString(@"Protocol")]) {
                protocol = generic;
            }
            
            if (protocol) {
                NSMutableArray *arr = @[].mutableCopy;
                NSArray *oldArr = [self.backend valueForKeyPath:obj.key];
                if ([oldArr isKindOfClass:[NSArray class]]) {
                    for (id json in oldArr) {
                        id model = YFProtocolModelCreate(protocol, json);
                        [arr addObject:model];
                    }
                }
                [self.backend setValue:arr forKeyPath:obj.key];
            }
        }
    }];
}


#pragma mark - Message Forward
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    // 根据用户调用的 setter、getter 查找字典实际 setter、getter 的方法签名
    __block SEL realSEL = sel;
    [self.protocolInfo.properties enumerateObjectsUsingBlock:^(YFPropertyInfo *obj, NSUInteger idx, BOOL *stop) {
        if (sel_isEqual(sel, obj.setter)) {
            realSEL = [self setterSelectorForBackendWithProperty:obj];
            *stop = YES;
        } else if (sel_isEqual(sel, obj.getter)) {
            realSEL = [self getterSelectorForBackendWithProperty:obj];
            *stop = YES;
        }
    }];
    return [self.backend methodSignatureForSelector:realSEL];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 标志已完成转发
    __block BOOL done = NO;
    [self.protocolInfo.properties enumerateObjectsUsingBlock:^(YFPropertyInfo *obj, NSUInteger idx, BOOL *stop) {
        if (sel_isEqual(invocation.selector, obj.setter)) {
            invocation.selector = [self setterSelectorForBackendWithProperty:obj];
            [self performPropertySetter:obj withInvocation:invocation];
            *stop = YES;
            done = YES;
        } else if (sel_isEqual(invocation.selector, obj.getter)) {
            invocation.selector = [self getterSelectorForBackendWithProperty:obj];
            [self performPropertyGetter:obj withInvocation:invocation];
            *stop = YES;
            done = YES;
        }
    }];
    
    // 默认转发所有非 setter、getter 方法
    if (!done) {
        [invocation invokeWithTarget:self.backend];
    }
}

- (SEL)setterSelectorForBackendWithProperty:(YFPropertyInfo *)pInfo {
    if (pInfo.flag & YFPropertyFlagStructType) {
        NSString *selStr = [NSString stringWithFormat:@"set%@:forKey:", pInfo.structType];
        return NSSelectorFromString(selStr);
    }
    return @selector(setValue:forKeyPath:);
}

- (SEL)getterSelectorForBackendWithProperty:(YFPropertyInfo *)pInfo {
    if (pInfo.flag & YFPropertyFlagStructType) {
        NSString *selStr = [NSString stringWithFormat:@"get%@ForKey:", pInfo.structType];
        return NSSelectorFromString(selStr);
    }
    return @selector(valueForKeyPath:);
}

- (void)performPropertySetter:(YFPropertyInfo *)pInfo withInvocation:(NSInvocation *)invocation {
    if (pInfo.flag & YFPropertyFlagNumberType) {
        #define YFPropertySetterNumberCase(_case_, _type_) \
            case _case_: { \
                _type_ arg; \
                [invocation getArgument:&arg atIndex:2]; \
                NSNumber *val = @(arg); \
                [invocation setArgument:&val atIndex:2]; }\
                break;
        
        switch (pInfo.encodeType) {
            YFPropertySetterNumberCase(YFPropertyEncodeTypeInt8, int8_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeUInt8, uint8_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeInt16, int16_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeUInt16, uint16_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeInt32, int32_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeUInt32, uint32_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeInt64, int64_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeUInt64, uint64_t)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeFloat, float)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeDouble, double)
            YFPropertySetterNumberCase(YFPropertyEncodeTypeBool, BOOL)
            default:
                break;
        }
    }
    NSString *key = pInfo.key;
    [invocation setArgument:&key atIndex:3];
    [invocation invokeWithTarget:self.backend];
}

- (void)performPropertyGetter:(YFPropertyInfo *)pInfo withInvocation:(NSInvocation *)invocation {
    NSString *key = pInfo.key;
    [invocation setArgument:&key atIndex:2];
    [invocation invokeWithTarget:self.backend];
    
    if (pInfo.flag & YFPropertyFlagNumberType) {
        #define YFPropertyGetterNumberCase(_case_, _type_, _tran_) \
            case _case_: { \
                _type_ ret = [(NSNumber *)val _tran_]; \
                [invocation setReturnValue:&ret]; } \
                break;
        id val;
        [invocation getReturnValue:&val];
        if (val) {
            switch (pInfo.encodeType) {
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeInt8, int8_t, charValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeUInt8, uint8_t, unsignedCharValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeInt16, int16_t, shortValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeUInt16, uint16_t, unsignedShortValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeInt32, int32_t, intValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeUInt32, uint32_t, unsignedIntValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeInt64, int64_t, longLongValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeUInt64, uint64_t, unsignedLongLongValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeFloat, float, floatValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeDouble, double, doubleValue)
                YFPropertyGetterNumberCase(YFPropertyEncodeTypeBool, BOOL, boolValue)
                default:
                    break;
            }
        }
    }
}

@end


#pragma mark - Function Helper
NSDictionary *__YFDictionaryWithJSON(id json) {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

__attribute__((overloadable)) id YFProtocolModelCreate(Protocol *protocol) {
    return YFProtocolModelCreate(protocol, nil);
}

__attribute__((overloadable)) id YFProtocolModelCreate(Protocol *protocol, id json) {
    if (!protocol) return nil;
    if (!json) {
        return [[YFProtocolModel alloc] initWithProtocol:protocol json:nil];
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
        return [[YFProtocolModel alloc] initWithProtocol:protocol json:json];
    }
    if ([json isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr;
        for (id obj in json) {
            id model = YFProtocolModelCreate(protocol, obj);
            if (!arr) arr = @[].mutableCopy;
            if (model) [arr addObject:model];
        }
        return arr;
    }
    id jsonObject = __YFDictionaryWithJSON(json);
    return YFProtocolModelCreate(protocol, jsonObject);
}


#pragma mark - YFProtocolModelDeug Implementation
@implementation NSDictionary (YFProtocolModelDeug)
- (NSString *)descriptionWithLevel:(int)level {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"%*s{\n", level * kIntent, ""];
    level++;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
            [desc appendString:[obj descriptionWithLevel:level]];
        } else {
            [desc appendFormat:@"%*s%@ : %@", level * kIntent, "", key, obj];
        }
        [desc appendString:@",\n"];
    }];
    level--;
    [desc appendFormat:@"%*s}\n", level * kIntent, ""];
    return desc;
}
@end


@implementation NSArray (YFProtocolModelDeug)
- (NSString *)descriptionWithLevel:(int)level {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"%*s(\n", level * kIntent, ""];
    level++;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
            [desc appendString:[obj descriptionWithLevel:level]];
        } else {
            [desc appendFormat:@"%*s%@", level * kIntent, "", obj];
        }
        [desc appendString:@"\n"];
    }];
    level--;
    [desc appendFormat:@"%*s)\n", level * kIntent, ""];
    return desc;
}
@end
