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

- (void)testProtocol {
    NSDictionary *dict = @{
                           @"name" : @"laizw",
                           @"sex"  : @"man"
                           };
    YFModel<Human> *human = [YFModel modelWithJSON:dict];
    NSLog(@"name : %@, sex : %@", human.name, human[@"sex"]);
}

- (void)testModels {
    NSDictionary *dict = @{
                           @"text" : @"hello",
                           @"user" : @{
                                       @"name" : @"laizw",
                                       @"sex"  : @"man"
                                       }
                           };
    YFModel<Message> *msg = [YFModel modelWithJSON:dict];
    NSLog(@"%@ say: %@", msg.user.name, msg.text);
}

- (void)testJSONString {
    NSString *jsonString = @"{\"name\":\"laizw\", \"sex\":\"man\", \"age\":20}";
    
    YFModel<Human> *human = [YFModel modelWithJSON:jsonString];
    NSLog(@"name : %@, sex : %@, age : %@", human.name, human.sex, human[@"age"]);
}



@end
