//
//  YFProtocolModelNSTypeTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/2/9.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolModelNSTypeTests : XCTestCase
@end

@protocol NSStringTypeTest
@property (nonatomic, copy) NSString *string;
@property (nonatomic, strong) NSMutableString *mutableString;
@end

@protocol NSValueTypeTest
@property (nonatomic, strong) NSValue *value;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSDecimalNumber *decimalNumer;
@end

@protocol NSDataTypeTest
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableData *mutableData;
@end

@protocol NSDateTypeTest
@property (nonatomic, strong) NSDate *date;
@end

@implementation YFProtocolModelNSTypeTests

- (void)testString {
    id<NSStringTypeTest> test = YFProtocolModelCreate(@protocol(NSStringTypeTest));
    test.string = @"string";
    test.mutableString = [NSMutableString string];
    [test.mutableString appendString:@"mutable string"];
    NSLog(@"%@", test);
}

- (void)testValue {
    id<NSValueTypeTest> test = YFProtocolModelCreate(@protocol(NSValueTypeTest));
    test.value = [NSValue valueWithCGRect:CGRectZero];
    test.number = @(99);
    test.decimalNumer = [NSDecimalNumber decimalNumberWithString:@"1.2"];
    NSLog(@"%@", test);
}

- (void)testData {
    id<NSDataTypeTest> test = YFProtocolModelCreate(@protocol(NSDataTypeTest));
    test.data = [@"string 2 data" dataUsingEncoding:NSUTF8StringEncoding];
    test.mutableData = [NSMutableData data];
    [test.mutableData appendData:[@"mutable data" dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@", test);
}

- (void)testDate {
    id<NSDateTypeTest> test = YFProtocolModelCreate(@protocol(NSDateTypeTest));
    test.date = [NSDate date];
    NSLog(@"%@", test);
}

@end
