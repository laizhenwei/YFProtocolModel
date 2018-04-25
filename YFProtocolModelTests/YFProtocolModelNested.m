//
//  YFProtocolModelNested.m
//  YFProtocolModelTests
//
//  Created by laizw on 2018/2/11.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YFProtocolModel.h"

@interface YFProtocolModelNested : XCTestCase
@end

@protocol Author
@property (nonatomic, copy) NSString *name;
@end

@protocol Book
@property (nonatomic, copy) NSString *name;
@property NSArray<NSString *> *strs;
@property (nonatomic, strong) id<Author> author;
@end

@implementation YFProtocolModelNested

- (void)testNestedModel {
    id<Book> book = YFProtocolModelCreate(@protocol(Book));
    book.name = @"book name";
    book.author = YFProtocolModelCreate(@protocol(Author));
    book.author.name = @"laizw";
    NSLog(@"%@ %@ %@ %@", book.name, book.author.name, book.author, book);
}

- (void)testJSON2NestedModel {
    NSDictionary *dict = @{@"name": @"book_name", @"author": @{@"name": @"laizw"}};
    id<Book> book = YFProtocolModelCreate(@protocol(Book), dict);
    NSLog(@"%@ %@ %@", book.author, book.author, book.author);
}

@end
