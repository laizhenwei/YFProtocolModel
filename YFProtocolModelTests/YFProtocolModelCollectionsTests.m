//
//  YFProtocolModelCollectionsTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/2/9.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolModelCollectionsTests : XCTestCase
@end

@protocol NSArrayTests
@property (nonatomic, copy) NSArray *array;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@end

@protocol NSDictionaryTests
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic, strong) NSMutableDictionary *mutableDict;
@end

@protocol NSSetTest
@property (nonatomic, copy) NSSet *set;
@property (nonatomic, strong) NSMutableSet *mutableSet;
@end

@implementation YFProtocolModelCollectionsTests

- (void)testArray {
    id<NSArrayTests> test = YFProtocolModelCreate(@protocol(NSArrayTests));
    test.array = @[@"1", @"test"];
    test.mutableArray = @[].mutableCopy;
    [test.mutableArray addObject:@"testing"];
    NSLog(@"%@", test);
}

- (void)testDict {
    id<NSDictionaryTests> test = YFProtocolModelCreate(@protocol(NSDictionaryTests));
    test.dict = @{@"1": @"test"};
    test.mutableDict = @{}.mutableCopy;
    [test.mutableDict setObject:@"hello" forKey:@"saying"];
    NSLog(@"%@", test);
}

- (void)testSet {
    id<NSSetTest> test = YFProtocolModelCreate(@protocol(NSSetTest));
    test.set = [NSSet setWithObject:@1];
    test.mutableSet = [NSMutableSet setWithObjects:@1, @2, nil];
    NSLog(@"%@", test);
    [test.mutableSet addObject:@3];
    [test.mutableSet addObject:@1];
    NSLog(@"%@", test);
}

- (void)testJson2EditableCollectionModel {
    NSDictionary *json = @{@"mutableArray": @[@"1", @"2", @"3"]};
    id<NSArrayTests> test = YFProtocolModelCreate(@protocol(NSArrayTests), json);
    NSLog(@"%@", test);
    [test.mutableArray addObject:@"4"];
    NSLog(@"%@", test);
}

@end
