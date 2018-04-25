# YFProtocolModel

iOS 去 Model 化的一种实践方式，通过 `Protocol` 的方式直接使用 `Model`。

### 前言

不知道你有没有发现，现在项目越做越大，Model 越来越多，越来越重...

其实很多时候，我们使用 Model 的目的只是为了方便储存和读取一些数据，它的地位几乎等同于 `Dictionary`，只是 `Dictionary` 没有友好的访问方式罢了。

如果认同上面我说的话，或许你会需要 `Protocol Model`。


### 什么是 Protocol Model ？

Model = Protocol + Dictionary

这就是 Protocol Model。

利用 Protocol 声明和 Dictionary 做 backend 支撑，不要创建专门的 Model 类便可以优雅的使用 Model。

同时，你可以理解为这是为 `Dictionary` 增加一个优雅的访问方式。

```objc
@protocol Human
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@end

id<Human> human = YFProtocolModelCreate(@protocol(Human));
human.name = @"laizw";
human.age = 14;
```

### 功能

> 目前 `Protocol Model` 只是个雏，需要轻点儿折腾~

- [x] NSObject 类型
- [x] 值类型（int, float, BOOL 等）
- [x] 常用结构体（CGRect，CGPoint 等）
- [x] 自定义结构体
- [x] 自定义 `setter` 和 `getter`
- [x] JSON 转 Protocol Model
- [ ] ~~@optional 属性 (当前 `objc` 不支持读取 `@optional` 属性列表)~~
- [x] 协议继承
- [x] key 和属性名映射
- [x] Model 嵌套
- [x] 容器类属性
- [ ] 类型转换
- [ ] Property Attribute 特性 (copy、weak等)
- [ ] ······

#### JSON 转 Protocol Model

```objc
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
```

#### 协议继承

```objc
@protocol Student <Human>
@property (nonatomic, assign) NSInteger number;
@end

- (void)testInteritance {
    NSDictionary *json = @{@"name": @"李四", @"age": @22, @"number": @123456};
    id<Student> stu = YFProtocolModelCreate(@protocol(Student), json);
    
    XCTAssertTrue([stu.name isEqualToString:@"李四"]);
    XCTAssertEqual(stu.age, 22);
    XCTAssertEqual(stu.number, 123456);
}
```

#### 使用 Number 值类型和结构体

众所周知，`NSDictionary` 是只能存入 Object 类型，不支持 struct、值类型等，所以在赋值和读取的时候 `Protocol Model` 会做一层装箱和拆箱处理。

##### Number 值类型

因为内置了自动装箱拆箱机制，在使用 Number 值类型的时候可以当做正常 object 属性来使用。

##### 结构体

内置支持一些常用的结构体

```objc
YFProtocolRegisterStruct(CGRect)
YFProtocolRegisterStruct(CGSize)
YFProtocolRegisterStruct(CGPoint)
YFProtocolRegisterStruct(NSRange)
YFProtocolRegisterStruct(UIOffset)
YFProtocolRegisterStruct(CGVector)
YFProtocolRegisterStruct(UIEdgeInsets)
YFProtocolRegisterStruct(CGAffineTransform)
```

如果你需要用到其他 struct 或者需要自定义 struct，需要先注册该类型。

##### 自定义结构体

需要注意，定义结构体的时候不能定义匿名结构体

```objc
// ❌ 错误
typedef struct {
    int arg;
} MyStruct;

// ✅ 正确
typedef struct MyStruct {
    int arg;
} MyStruct;

// 注册只需要添加这么一句话
YFProtocolRegisterStruct(MyStruct)
```

如果不想定义的问题，可以使用内置提供的方法，定义后自动注册

```objc
YFProtocolDefineStruct(MyStruct, {
    BOOL flag;
    NSInteger num;
})
```

##### 属性名映射

通常，我们从接口得到的数据字段命名真是~~千奇百怪~~，这时候我们迫切需要属性名和 key 之间的映射。

一般的 JSON to Model 都实现了这个功能，但是他们都是基于 Class 实现的，基于 Class 可以很方便实现对应转换方法来进行数据处理，但是我们是 Protocol Model，那得需要点技巧了。。

```objc
@protocol Feed
@property NSString *uuid;
@end

@protocol implementation(Feed)
+ (NSDictionary<NSString *,id> *)modelPropertyKeyMapper {
    return @{
             @"uuid": @"id",
             };
}
@end
```

这样我们就可以随心所欲的操作数据了。

##### 容器类属性

支持 Protocol 容器嵌套

```objc
@protocol Comment
@property NSString *uuid;
@end

@protocol Post
@property NSString *uuid;
@property NSArray<Comment> *comments;
@end

@protocol implementation(Post)
+ (NSDictionary<NSString *, Protocol *> *)modelContainerPropertyGenericClass {
    return @{
             @"comments": @protocol(Comment)
             };
}
@end

- (void)testContainerGenerics {
    NSDictionary *json = @{@"uuid": @"wonderful",
                           @"comments": @[
                                   @{@"uuid": @"1"},
                                   @{@"uuid": @"2"},
                                   @{@"uuid": @"3"},
                                   @{@"uuid": @"4"},
                                    ]
                           };
    id<Post> test = YFProtocolModelCreate(@protocol(Post), json);
}
```

