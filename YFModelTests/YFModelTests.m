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
@property (nonatomic, strong) NSArray<Human> *users;
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
    id<Human> human = [dict modelWithProtocol:@protocol(Human)];
    NSLog(@"name : %@, sex : %@", human.name, human[@"sex"]);
    
    XCTAssertNotNil(human);
    XCTAssert([human.name isEqualToString:@"laizw"]);
    XCTAssert([human[@"sex"] isEqualToString:@"man"]);

    human.name = @"lzw";
    XCTAssert([human.name isEqualToString:@"lzw"]);
}

- (void)testModelsContainsModels {
    NSDictionary *dict = @{
                           @"text" : @"hello",
                           @"user" : @{
                                   @"name" : @"laizw",
                                   @"sex"  : @"man"
                                   },
                           @"users" : @[
                                   @{
                                       @"name" : @"laizw",
                                       @"sex"  : @"male"
                                       },
                                   @{
                                       @"name" : @"lzw",
                                       @"sex"  : @"male"
                                       },
                                   @{
                                       @"name" : @"ywy",
                                       @"sex"  : @"female"
                                       }
                                   ]
                           };
    
    id<Message> msg = [[dict modelWithProtocol:@protocol(Message)] generic:^NSDictionary *{
        return @{@"user" : @"Human", @"users" : @protocol(Human)};
    }];
    NSLog(@"%@", msg.users);
    
    XCTAssertNotNil(msg);
    XCTAssert([msg.text isEqualToString:@"hello"]);
    XCTAssertNotNil(msg.user);
    XCTAssert([msg.user.name isEqualToString:@"laizw"]);
    XCTAssert([msg.user.sex isEqualToString:@"man"]);
    XCTAssert(msg.users.count == 3);
    XCTAssert([[msg.users[2] sex] isEqualToString:@"female"]);
}

- (void)testJSONString {
    NSString *jsonString = @"{\"name\":\"laizw\", \"sex\":\"man\", \"age\":20}";
    
    id<Human> human = [jsonString modelWithProtocol:@protocol(Human)];
    NSLog(@"name : %@, sex : %@, age : %@", human.name, human.sex, human[@"age"]);
    
    XCTAssertNotNil(human);
    XCTAssert([human.name isEqualToString:@"laizw"]);
    XCTAssert([human[@"sex"] isEqualToString:@"man"]);
    XCTAssert([human.age isEqualToNumber:@20]);
}

@end
