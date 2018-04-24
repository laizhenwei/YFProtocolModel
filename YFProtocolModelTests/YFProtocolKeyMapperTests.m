//
//  YFProtocolKeyMapperTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/2/11.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"


@interface YFProtocolKeyMapperTests : XCTestCase
@end

@protocol CustomSetterGetter
@property (setter=setUserName:, getter=userName) NSString *name;
@end

@protocol CustomKeyMapper
@property (setter=setNickName:, getter=nickName) NSString *nic_name;
@end

@protocol CustomPropertyKeyMapper
@property NSString *uuid;
@end

@protocol implementation(CustomPropertyKeyMapper)
+ (NSDictionary<NSString *,id> *)modelPropertyKeyMapper {
    return @{
             @"uuid": @"id",
             };
}
@end

@implementation YFProtocolKeyMapperTests

- (void)testCutomKeyMapperProperty {
    id<CustomSetterGetter> test = YFProtocolModelCreate(@protocol(CustomSetterGetter));
    test.userName = @"name";
    NSLog(@"%@", test.userName);
}

- (void)testCutomKeyMapperJSON2Model {
    NSDictionary *dict = @{@"nic_name": @"laizw"};
    id<CustomKeyMapper> test = YFProtocolModelCreate(@protocol(CustomKeyMapper), dict);
    NSLog(@"%@ %@ %@", test.nickName, test.nic_name, test);
}

- (void)testCustomPropertyKeyMapper {
    NSDictionary *dict = @{@"id": @"1234"};
    id<CustomPropertyKeyMapper> test = YFProtocolModelCreate(@protocol(CustomPropertyKeyMapper), dict);
    NSLog(@"%@ %@", test, test.uuid);
    test.uuid = @"0000";
    NSLog(@"%@ %@", test, test.uuid);
}

@end
