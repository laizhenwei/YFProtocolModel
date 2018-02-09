//
//  YFProtocolModelStructTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/2/9.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolModelStructTests : XCTestCase
@end

// 两种注册 struct 方式
typedef struct ClassNumber {
    NSInteger grade, number;
} ClassNumber;

YFProtocolRegisterStruct(ClassNumber)

YFProtocolDefineStruct(MyStruct, {
    BOOL flag;
    NSInteger num;
})

@protocol TestStruct
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) ClassNumber classNumber;
@property (nonatomic, assign) MyStruct myStruct;
@end


@implementation YFProtocolModelStructTests

- (void)testStruct {
    id<TestStruct> testStruct = YFProtocolModelCreate(@protocol(TestStruct));
    testStruct.point = CGPointMake(100, 100);
    testStruct.classNumber = (ClassNumber){6,1};
    testStruct.myStruct = (MyStruct){YES, 100};
    
    XCTAssertTrue(CGPointEqualToPoint(testStruct.point, CGPointMake(100, 100)));
    XCTAssertEqual(testStruct.classNumber.grade, 6);
    XCTAssertEqual(testStruct.classNumber.number, 1);
    XCTAssertEqual(testStruct.myStruct.flag, YES);
    XCTAssertEqual(testStruct.myStruct.num, 100);
}

@end
