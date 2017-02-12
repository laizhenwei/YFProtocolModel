//
//  YFModelTests.m
//  YFModelTests
//
//  Created by laizw on 2017/2/6.
//  Copyright © 2017年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFModel.h"
#import <objc/runtime.h>

@protocol Human <NSObject>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) NSNumber *age;
@end

@protocol Message <NSObject>
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) YFModel<Human> *user;
@property (nonatomic, strong) NSString *create_at;
@end

@interface YFModelTests : XCTestCase
@end

@implementation YFModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleProtocolModel {
    NSDictionary *dict = @{
                           @"name" : @"laizw",
                           @"sex"  : @"man"
                           };
    YFModel<Human> *human = [YFModel modelWithJSON:dict];
    NSLog(@"name : %@, sex : %@", human.name, human[@"sex"]);
    
    XCTAssertNotNil(human);
    XCTAssert([human.name isEqualToString:@"laizw"]);
    XCTAssert([human[@"sex"] isEqualToString:@"man"]);
}

- (void)testModelsContainsModels {
    NSDictionary *dict = @{
                           @"text" : @"hello",
                           @"user" : @{
                                       @"name" : @"laizw",
                                       @"sex"  : @"man"
                                       }
                           };
    
    YFModel<Message> *msg = [YFModel modelWithJSON:dict];
    NSLog(@"%@ say: %@", msg.user.name, msg.text);
    
    XCTAssertNotNil(msg);
    XCTAssert([msg.text isEqualToString:@"hello"]);
    XCTAssertNotNil(msg.user);
    XCTAssert([msg.user.name isEqualToString:@"laizw"]);
    XCTAssert([msg.user.sex isEqualToString:@"man"]);
}

- (void)testJSONString {
    NSString *jsonString = @"{\"name\":\"laizw\", \"sex\":\"man\", \"age\":20}";
    
    YFModel<Human> *human = [YFModel modelWithJSON:jsonString];
    NSLog(@"name : %@, sex : %@, age : %@", human.name, human.sex, human[@"age"]);
    
    XCTAssertNotNil(human);
    XCTAssert([human.name isEqualToString:@"laizw"]);
    XCTAssert([human[@"sex"] isEqualToString:@"man"]);
    XCTAssert([human.age isEqualToNumber:@20]);
}

@end
