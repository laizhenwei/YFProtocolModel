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
@end

@implementation YFModel

#pragma mark - Method Resolve
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selStr = NSStringFromSelector(sel);
    if ([selStr componentsSeparatedByString:@":"].count > 2) return NO;
    
    if ([selStr hasPrefix:@"set"]) {
        class_addMethod(self.class, sel, (IMP)_DictionarySetter, "v@:@");
    } else {
        class_addMethod(self.class, sel, (IMP)_DictionaryGetter, "@@:");
    }
    return YES;
}

#pragma mark - Life Circle
- (id)initWithDict:(NSDictionary *)dict {
    if (!dict) return nil;
    if (self = [super init]) {
        self.dict = dict.mutableCopy;
    }
    return self;
}

- (id)initWithJSON:(id)json {
    return [YFModel modelWithJSON:json];
}

+ (id)modelWithJSON:(id)json {
    NSDictionary *dict = [self _dictionaryWithJSON:json];
    return [[YFModel alloc] initWithDict:dict];
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

#pragma mark - Model Convert
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

void _DictionarySetter(YFModel *self, SEL sel, id value) {
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

id _DictionaryGetter(YFModel *self, SEL sel) {
    NSString *key = NSStringFromSelector(sel);
    id value = [self.dict objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        YFModel *model = [YFModel modelWithJSON:value];
        [self.dict setValue:model forKey:key];
        return model;
    }
    return value;
}

@end
