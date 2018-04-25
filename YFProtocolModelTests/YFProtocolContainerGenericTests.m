//
//  YFProtocolContainerGenericTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/4/25.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolContainerGenericTests : XCTestCase

@end

@protocol Comment
@property NSString *uuid;
@end

@protocol Post
@property NSString *uuid;
@property NSArray<Comment> *comments;
@end

@protocol implementation(Post)
+ (NSDictionary<NSString *, Protocol *> *)modelContainerPropertyGenericClass {
    return @{
             @"comments": @protocol(Comment)
             };
}
@end

@implementation YFProtocolContainerGenericTests

- (void)testContainerGenerics {
    NSDictionary *json = @{@"uuid": @"wonderful",
                           @"comments": @[
                                   @{@"uuid": @"1"},
                                   @{@"uuid": @"2"},
                                   @{@"uuid": @"3"},
                                   @{@"uuid": @"4"},
                                    ]
                           };
    id<Post> test = YFProtocolModelCreate(@protocol(Post), json);
    NSLog(@"%@", [test.comments[3] uuid]);
}

@end
