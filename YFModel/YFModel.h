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

@property (nonatomic, unsafe_unretained) Protocol *protocol;

- (id)JSONObject;

- (id)generic:(NSDictionary *(^)())generic;

- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;

@end

@protocol YFModelInitialize <NSObject>
- (id)modelWithProtocol:(Protocol *)protocol;
@end

@interface NSDictionary (YFModel) <YFModelInitialize>
@end

@interface NSString (YFModel) <YFModelInitialize>
@end

@interface NSData (YFModel) <YFModelInitialize>
@end
