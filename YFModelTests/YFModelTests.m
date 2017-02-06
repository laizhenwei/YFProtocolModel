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

@protocol IPResult <NSObject>
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *location;
@end

@protocol IPResponse <NSObject>
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, strong) YFModel<IPResult> *result;
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

- (void)testDict {
    NSDictionary *dict = @{
                           @"code":@200,
                           @"reason":@"Return Successd!",
                           @"result": @{
                                        @"area":@"江苏省苏州市",
                                        @"location":@"电信"
                                        }
                           };
    
    YFModel<IPResponse> *ipRes = [YFModel modelWithDict:dict];
    ipRes.result[@"area"] = @"001";
    ipRes.code = @003;
    NSLog(@"code : %@, area : %@", ipRes.code, ipRes.result);
}

@end
