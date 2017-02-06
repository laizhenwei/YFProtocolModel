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

#pragma mark - Life Circle
- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.dict = dict.mutableCopy;
    }
    return self;
}

+ (id)modelWithDict:(NSDictionary *)dict {
    return [[YFModel alloc] initWithDict:dict];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.dict];
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
        YFModel *model = [YFModel modelWithDict:value];
        [self.dict setValue:model forKey:key];
        return model;
    }
    return value;
}

@end
