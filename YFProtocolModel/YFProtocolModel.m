//
//  YFProtocolModel.m
//  YFProtocolModel
//
//  Created by laizw on 2018/2/6.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import "YFProtocolModel.h"
#import "YFProtocolInfo.h"

YFProtocolRegisterStruct(CGRect)
YFProtocolRegisterStruct(CGSize)
YFProtocolRegisterStruct(CGPoint)
YFProtocolRegisterStruct(NSRange)
YFProtocolRegisterStruct(UIOffset)
YFProtocolRegisterStruct(CGVector)
YFProtocolRegisterStruct(UIEdgeInsets)
YFProtocolRegisterStruct(CGAffineTransform)

static inline SEL YFRealPropertySelector(YFPropertyInfo *pInfo, BOOL setter) {
    if (setter) {
        if (pInfo.flag & YFPropertyFlagStructType) {
            NSString *selStr = [NSString stringWithFormat:@"yf_protocol_model_set_%@:forKey:", pInfo.structType];
            return NSSelectorFromString(selStr);
        } else {
            return @selector(setValue:forKey:);
        }
    } else {
        if (pInfo.flag & YFPropertyFlagStructType) {
            NSString *selStr = [NSString stringWithFormat:@"yf_protocol_model_get_%@ForKey:", pInfo.structType];
            return NSSelectorFromString(selStr);
        } else {
            return @selector(valueForKey:);
        }
    }
}

@interface YFProtocolModel : NSProxy <YFProtocolModel>
@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, strong) YFProtocolInfo *protocolInfo;
@property (nonatomic, strong) NSMutableDictionary *backend;

- (id)initWithProtocol:(Protocol *)protocol json:(NSDictionary *)json;
@end

@implementation YFProtocolModel

- (id)initWithProtocol:(Protocol *)protocol json:(NSDictionary *)json {
    self.backend = (json ?: @{}).mutableCopy;
    self.protocol = protocol;
    self.protocolInfo = [YFProtocolInfo infoWithProtocol:protocol];
    return self;
}

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"<%@ %p> \n", self.protocolInfo.name, self];
    [desc appendString:@"{\n"];
    [self.backend enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [desc appendFormat:@"\t%@: %@\n", key, obj];
    }];
    [desc appendString:@"}"];
    return desc;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block SEL realSEL = sel;
    [self.protocolInfo.properties enumerateObjectsUsingBlock:^(YFPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sel_isEqual(sel, obj.setter)) {
            realSEL = YFRealPropertySelector(obj, YES);
            *stop = YES;
        } else if (sel_isEqual(sel, obj.getter)) {
            realSEL = YFRealPropertySelector(obj, NO);
            *stop = YES;
        }
    }];
    
    return [self.backend methodSignatureForSelector:realSEL];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = invocation.selector;
    
    __block YFPropertyInfo *pInfo = nil;
    [self.protocolInfo.properties enumerateObjectsUsingBlock:^(YFPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sel_isEqual(sel, obj.setter) || sel_isEqual(sel, obj.getter)) {
            pInfo = obj;
            *stop = YES;
        }
    }];
    
    if (pInfo) {
        if (sel_isEqual(sel, pInfo.setter)) {
            [self performPropertySetter:pInfo withInvocation:invocation];
        } else {
            [self performPropertyGetter:pInfo withInvocation:invocation];
        }
    } else {
        [invocation invokeWithTarget:self.backend];
    }
}

- (void)performPropertySetter:(YFPropertyInfo *)property withInvocation:(NSInvocation *)invocation {
    if (property.flag & YFPropertyFlagNumberType) {
        #define YFPropertySetterNumberCase(_case_, _type_) \
            case _case_: { \
                _type_ arg; \
                [invocation getArgument:&arg atIndex:2]; \
                NSNumber *val = @(arg); \
                [invocation setArgument:&val atIndex:2]; }\
                break;
        
        switch (property.encodeType) {
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
    NSString *key = property.name;
    invocation.selector = YFRealPropertySelector(property, YES);
    [invocation setArgument:&key atIndex:3];
    [invocation invokeWithTarget:self.backend];
}

- (void)performPropertyGetter:(YFPropertyInfo *)property withInvocation:(NSInvocation *)invocation {
    NSString *key = property.name;
    invocation.selector = YFRealPropertySelector(property, NO);
    [invocation setArgument:&key atIndex:2];
    [invocation invokeWithTarget:self.backend];
    
    if (property.flag & YFPropertyFlagNumberType) {
        #define YFPropertyGetterNumberCase(_case_, _type_, _tran_) \
            case _case_: { \
                _type_ ret = [(NSNumber *)val _tran_]; \
                [invocation setReturnValue:&ret]; } \
                break;
        id val;
        [invocation getReturnValue:&val];
        if (val) {
            switch (property.encodeType) {
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

NSDictionary * YFDictionaryWithJSON(id json) {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
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
    id jsonObject = YFDictionaryWithJSON(json);
    return YFProtocolModelCreate(protocol, jsonObject);
}



