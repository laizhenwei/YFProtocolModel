//
//  YFProtocolModelTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/2/8.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolModelTests : XCTestCase
@end


@protocol Human
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@end

@protocol Student <Human>
@property (nonatomic, assign) NSInteger number;
@end

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

@implementation YFProtocolModelTests

- (void)testNewProtocolModel {
    id<Human> human = YFProtocolModelCreate(@protocol(Human));
    human.name = @"laizw";
    human.age = 14;
    XCTAssertTrue([human.name isEqualToString:@"laizw"]);
    XCTAssertEqual(human.age, 14);
}

- (void)testDictJson2ProtocolModel {
    NSDictionary *json = @{@"name": @"李四", @"age": @24};
    id<Human> human = YFProtocolModelCreate(@protocol(Human), json);
    XCTAssertTrue([human.name isEqualToString:@"李四"]);
    XCTAssertEqual(human.age, 24);
}

- (void)testJsonString2ProtocolModel {
    NSString *json = @"{\"name\":\"petter\",\"age\":30}";
    id<Human> human = YFProtocolModelCreate(@protocol(Human), json);
    XCTAssertTrue([human.name isEqualToString:@"petter"]);
    XCTAssertEqual(human.age, 30);
}

- (void)testInteritance {
    NSDictionary *json = @{@"name": @"李四", @"age": @22, @"number": @123456};
    id<Student> stu = YFProtocolModelCreate(@protocol(Student), json);
    XCTAssertTrue([stu.name isEqualToString:@"李四"]);
    XCTAssertEqual(stu.age, 22);
    XCTAssertEqual(stu.number, 123456);
}

- (void)testStruct {
    id<TestStruct> testStruct = YFProtocolModelCreate(@protocol(TestStruct));
    testStruct.point = CGPointMake(100, 100);
    testStruct.classNumber = (ClassNumber){6,1};;
    testStruct.myStruct = (MyStruct){YES, 100};
    XCTAssertTrue(CGPointEqualToPoint(testStruct.point, CGPointMake(100, 100)));
    XCTAssertEqual(testStruct.classNumber.grade, 6);
    XCTAssertEqual(testStruct.classNumber.number, 1);
    XCTAssertEqual(testStruct.myStruct.flag, YES);
    XCTAssertEqual(testStruct.myStruct.num, 100);
}

@end
