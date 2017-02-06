# YFModel

iOS 去 Model 化的一种实践方式，通过 `Protocol` + `YFModel` 的方式使用一个 `Model`。

## 使用

**JSON(Dictionary) + Protocol -> Model**

```objc

@protocol Human <NSObject>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@end

NSDictionary *dict = @{
                       @"name" : @"laizw",
                       @"sex"  : @"man"
                       };
YFModel<Human> *human = [YFModel modelWithJSON:dict];
// 直接访问 或者 使用下标 都可以
NSLog(@"name : %@, sex : %@", human.name, human[@"sex"]);

----------
name : laizw, sex : man

```

**JSONString + Protocol -> Model**

```objc

@protocol Human <NSObject>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) NSNumber *age;
@end

NSString *jsonString = @"{\"name\":\"laizw\", \"sex\":\"man\", \"age\":20}";
YFModel<Human> *human = [YFModel modelWithJSON:jsonString];
NSLog(@"name : %@, sex : %@, age : %@", human.name, human.sex, human[@"age"]);

----------
name : laizw, sex : man, age : 20

```

**Model 嵌套**

```objc

@protocol Human <NSObject>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@end

@protocol Message <NSObject>
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) YFModel<Human> *user;
@end

NSDictionary *dict = @{
                       @"text" : @"hello",
                       @"user" : @{
                                   @"name" : @"laizw",
                                   @"sex"  : @"man"
                                   }
                       };
YFModel<Message> *msg = [YFModel modelWithJSON:dict];
NSLog(@"%@ say: %@", msg.user.name, msg.text);

----------
laizw say: hello

```

## 待解决

1. key 和 property 必须一致，且首字母必须小写
2. 不支持类型装换 (Date...)
3. 不支持数组模型嵌套
