//
//  YFProtocolModelKVOTests.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/4/25.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolModelKVOTests : XCTestCase
@end

@protocol KVOModelTests <YFProtocolModel>
@property NSString *name;
@end

@implementation YFProtocolModelKVOTests

- (void)testKVOProtocolModel {
    id<KVOModelTests> test = YFProtocolModelCreate(@protocol(KVOModelTests));
    [test addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    test.name = @"1";
    test.name = @"2";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change[NSKeyValueChangeNewKey]);
}

@end
