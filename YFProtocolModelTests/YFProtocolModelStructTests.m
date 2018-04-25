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

// - 手动注册
YFProtocolRegisterStruct(ClassNumber)

// - 自动注册
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
    
    id<TestStruct> test = YFProtocolModelCreate(@protocol(TestStruct));
    test.point = CGPointMake(100, 100);
    test.classNumber = (ClassNumber){6,1};
    test.myStruct = (MyStruct){YES, 100};
    
    XCTAssertTrue(CGPointEqualToPoint(test.point, CGPointMake(100, 100)));
    XCTAssertEqual(test.classNumber.grade, 6);
    XCTAssertEqual(test.classNumber.number, 1);
    XCTAssertEqual(test.myStruct.flag, YES);
    XCTAssertEqual(test.myStruct.num, 100);
}

@end
