//
//  YFProtocolInfo.m
//  YFProtocolModel
//
//  Created by laizw on 2018/2/6.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import "YFProtocolInfo.h"

YFPropertyEncodeType YFPropertyEncodeGetType(const char *type) {
    size_t len = strlen(type);
    if (len == 0) return YFPropertyEncodeTypeUnknown;

    switch (*type) {
        case 'v': return YFPropertyEncodeTypeVoid;
        case 'B': return YFPropertyEncodeTypeBool;
        case 'c': return YFPropertyEncodeTypeInt8;
        case 'C': return YFPropertyEncodeTypeUInt8;
        case 's': return YFPropertyEncodeTypeInt16;
        case 'S': return YFPropertyEncodeTypeUInt16;
        case 'i': return YFPropertyEncodeTypeInt32;
        case 'I': return YFPropertyEncodeTypeUInt32;
        case 'l': return YFPropertyEncodeTypeInt32;
        case 'L': return YFPropertyEncodeTypeUInt32;
        case 'q': return YFPropertyEncodeTypeInt64;
        case 'Q': return YFPropertyEncodeTypeUInt64;
        case 'f': return YFPropertyEncodeTypeFloat;
        case 'd': return YFPropertyEncodeTypeDouble;
        case 'D': return YFPropertyEncodeTypeLongDouble;
        case '#': return YFPropertyEncodeTypeClass;
        case ':': return YFPropertyEncodeTypeSEL;
        case '*': return YFPropertyEncodeTypeCString;
        case '^': return YFPropertyEncodeTypePointer;
        case '[': return YFPropertyEncodeTypeCArray;
        case '(': return YFPropertyEncodeTypeUnion;
        case '{': return YFPropertyEncodeTypeStruct;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return YFPropertyEncodeTypeBlock;
            else
                return YFPropertyEncodeTypeObject;
        }
        default: return YFPropertyEncodeTypeUnknown;
    }
}

static inline BOOL YFPropertyEncodeTypeIsNumber(YFPropertyEncodeType encodeType) {
    switch (encodeType) {
        case YFPropertyEncodeTypeBool:
        case YFPropertyEncodeTypeInt8:
        case YFPropertyEncodeTypeUInt8:
        case YFPropertyEncodeTypeInt16:
        case YFPropertyEncodeTypeUInt16:
        case YFPropertyEncodeTypeInt32:
        case YFPropertyEncodeTypeUInt32:
        case YFPropertyEncodeTypeInt64:
        case YFPropertyEncodeTypeUInt64:
        case YFPropertyEncodeTypeFloat:
        case YFPropertyEncodeTypeDouble:
        case YFPropertyEncodeTypeLongDouble: return YES;
        default: return NO;
    }
}


@implementation YFPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (property == NULL) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    _property = property;
    
    _name = [NSString stringWithUTF8String:property_getName(property)];
    unsigned int count = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &count);
    
    _flag = 0;
    for (int i = 0; i < count; i++) {
        switch (attrs[i].name[0]) {
            case 'G':
                _flag |= YFPropertyFlagCustomGetter;
                _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                break;
            case 'S':
                _flag |= YFPropertyFlagCustomSetter;
                _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                break;
            case 'R':
                _flag |= YFPropertyFlagReadonly;
                break;
            case 'T':
                _type = [NSString stringWithUTF8String:attrs[i].value];
                _encodeType = YFPropertyEncodeGetType(attrs[i].value);
                
                NSScanner *scanner = [NSScanner scannerWithString:_type];
                if (![scanner scanString:@"@\"" intoString:NULL]) {
                    if (YFPropertyEncodeTypeIsNumber(_encodeType)) {
                        _flag |= YFPropertyFlagNumberType;
                    } else if ([scanner scanString:@"{" intoString:NULL]) {
                        _flag |= YFPropertyFlagStructType;
                        NSString *structType = nil;
                         if ([scanner scanUpToString:@"=" intoString:&structType]) {
                             if (structType.length) {
                                 _structType = structType;
                             }
                         }
                    }
                    continue;
                }
                
                // object type
                _flag |= YFPropertyFlagOjectType;
                
                NSString *className;
                if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&className]) {
                    _flag |= YFPropertyFlagProtocolType;
                    if (className.length) _type = className;
                }
                
                NSMutableArray *generics;
                while ([scanner scanString:@"<" intoString:NULL]) {
                    NSString *generic = nil;
                    if ([scanner scanUpToString:@">" intoString: &generic]) {
                        if (generic.length) {
                            if (!generics) generics = [NSMutableArray new];
                            [generics addObject:generic];
                        }
                    }
                    [scanner scanString:@">" intoString:NULL];
                }
                _generics = generics;
                break;
        }
    }
    
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    if (!_getter) {
        _getter = NSSelectorFromString(_name);
    }
    if (!_setter) {
        _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
    }
    
    return self;
}
@end

@implementation YFProtocolInfo

+ (instancetype)infoWithProtocol:(Protocol *)protocol {
    static NSMutableDictionary *caches;
    static dispatch_once_t one;
    static dispatch_semaphore_t lock;
    dispatch_once(&one, ^{
        caches = @{}.mutableCopy;
        lock = dispatch_semaphore_create(1);
    });
    
    NSString *name = NSStringFromProtocol(protocol);
   
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    YFProtocolInfo *info = [caches objectForKey:name];
    dispatch_semaphore_signal(lock);
    
    if (!info) {
        info = [[YFProtocolInfo alloc] initWithProtocol:protocol];
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [caches setValue:info forKey:name];
        dispatch_semaphore_signal(lock);
    }
    return info;
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _name = NSStringFromProtocol(protocol);
        [self loadPropertiesForProtocol:protocol];
    }
    return self;
}

- (void)loadPropertiesForProtocol:(Protocol *)protocol {
    
    BOOL isRequired[2] = {YES, NO};
    NSMutableArray *properties;
    unsigned int count = 0;
    for (int n = 0; n < 2; n++) {
        objc_property_t *plist = protocol_copyPropertyList2(self.protocol, &count, isRequired[n], YES);
        for (int i = 0; i < count; i++) {
            YFPropertyInfo *pInfo = [[YFPropertyInfo alloc] initWithProperty:plist[i]];
            if (!properties) properties = @[].mutableCopy;
            [properties addObject:pInfo];
        }
        if (plist) {
            free(plist);
            plist = NULL;
        }
    }
    
    unsigned int protoCount;
    Protocol *__unsafe_unretained *protocolList = protocol_copyProtocolList(protocol, &protoCount);
    for (int i = 0; i < protoCount; i++) {
        YFProtocolInfo *info = [YFProtocolInfo infoWithProtocol:protocolList[i]];
        if (info.properties.count) {
            [properties addObjectsFromArray:info.properties];
        }
    }
    if (protocolList) {
        free(protocolList);
        protocolList = NULL;
    }
    
    _properties = [properties copy];
}

@end

