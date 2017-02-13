//
//  YFModel.m
//  YFModelDemo
//
//  Created by laizw on 2017/2/6.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import "YFModel.h"
#import <objc/runtime.h>

@interface YFModel ()
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSDictionary *generic;
@end

@implementation YFModel

#pragma mark - Life Circle
- (id)initWithDict:(NSDictionary *)dict protocol:(Protocol *)protocol {
    if (!dict) return nil;
    if (self = [super init]) {
        self.dict = dict.mutableCopy;
        self.protocol = protocol;
    }
    return self;
}

+ (id)modelWithJSON:(id)json protocol:(Protocol *)protocol {
    NSDictionary *dict = [self _dictionaryWithJSON:json];
    return [[YFModel alloc] initWithDict:dict protocol:protocol];
}

#pragma mark - Overwrite
- (NSString *)description {
    return [self.dict description];
}

- (NSString *)descriptionWithLocale:(id)locale {
    return [self description];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self.dict objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self.dict setObject:obj forKey:key];
}

#pragma mark - Public
- (id)JSONObject {
    return [self.dict copy];
}

- (id)JSONStrng {
    NSData *data = self.JSONData;
    if (data.length == 0) return nil;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id)JSONData {
    id jsonObject = [self JSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (id)generic:(NSDictionary *(^)())generic {
    if (generic) self.generic = [generic() copy];
    return self;
}

#pragma mark - Private
+ (NSDictionary *)_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dict = nil;
    NSData *data = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        data = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        data = json;
    }
    if (data) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        if (![dict isKindOfClass:[NSDictionary class]]) dict = nil;
    }
    return dict;
}

void _YFSetter(YFModel *self, SEL sel, id value) {
    NSMutableString *key = [NSStringFromSelector(sel) mutableCopy];
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    NSString *first = [[key substringToIndex:1] lowercaseString];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:first];
    
    if (value) {
        [self.dict setObject:value forKey:key];
    } else {
        [self.dict removeObjectForKey:key];
    }
}

id _YFGetter(YFModel *self, SEL sel) {
    NSString *key = NSStringFromSelector(sel);
    id value = [self.dict objectForKey:key];
    id model = [self genericModelForProperty:key withValue:value];
    if (model) {
        [self.dict setObject:model forKey:key];
        return model;
    }
    return value;
}

- (Protocol *)genericForProperty:(NSString *)property {
    id protocol = self.generic[property];
    if (!protocol) return nil;
    if ([protocol isKindOfClass:[NSString class]]) return NSProtocolFromString(protocol);
    return protocol;
}

- (id)genericModelForProperty:(NSString *)key withValue:(id)value {
    if (![value conformsToProtocol:@protocol(NSFastEnumeration)]) return nil;
    Protocol *protocol = [self genericForProperty:key];
    if (!protocol) return nil;
    id model;
    if ([value isKindOfClass:[NSDictionary class]]) {
        model = [value modelWithProtocol:protocol];
    } else if ([value isKindOfClass:[NSArray class]] && [value count]) {
        if ([value[0] isKindOfClass:self.class]) return value;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[value count]];
        for (id obj in value) {
            id val = [obj modelWithProtocol:protocol];
            if (val) [arr addObject:val];
        }
        model = [arr copy];
    } else if ([value isKindOfClass:[NSSet class]] && [value count]) {
        if ([[value anyObject] isKindOfClass:self.class]) return value;
        NSMutableSet *set = [NSMutableSet setWithCapacity:[value count]];
        for (id obj in value) {
            id val = [obj modelWithProtocol:protocol];
            if (val) [set addObject:val];
        }
        model = [set copy];
    }
    return model;
}

#pragma mark - Method Resolve
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selStr = NSStringFromSelector(sel);
    if ([selStr componentsSeparatedByString:@":"].count > 2)
        return [super resolveInstanceMethod:sel];
    
    if ([selStr hasPrefix:@"set"]) {
        class_addMethod(self.class, sel, (IMP)_YFSetter, "v@:@");
    } else {
        class_addMethod(self.class, sel, (IMP)_YFGetter, "@@:");
    }
    return YES;
}

@end

@implementation NSDictionary (YFModel)
- (id)modelWithProtocol:(Protocol *)protocol {
    return [YFModel modelWithJSON:self protocol:protocol];
}
@end

@implementation NSString (YFModel)
- (id)modelWithProtocol:(Protocol *)protocol {
    return [YFModel modelWithJSON:self protocol:protocol];
}
@end

@implementation NSData (YFModel)
- (id)modelWithProtocol:(Protocol *)protocol {
    return [YFModel modelWithJSON:self protocol:protocol];
}
@end
