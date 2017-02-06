//
//  YFModel.h
//  YFModelDemo
//
//  Created by laizw on 2017/2/6.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double YFModelVersionNumber;
FOUNDATION_EXPORT const unsigned char YFModelVersionString[];

@interface YFModel : NSObject

- (id)initWithJSON:(id)json;
+ (id)modelWithJSON:(id)json;

- (id)JSONObject;
//- (id)JSONStrng;
//- (id)JSONData;

- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end
