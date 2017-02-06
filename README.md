# YFModel

iOS 去 Model 化的一种实践方式，通过 `Protocol` + `YFModel` 的方式使用一个 `Model`。

## 使用

`YFModel` 的实践的方式是 `YFModel` + `Protocol`

```objc

@protocol IPResult <NSObject>
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *location;
@end

@protocol IPResponse <NSObject>
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, strong) YFModel<IPResult> *result;
@end


NSDictionary *dict = @{
                       @"code" : @200,
                       @"reason" : @"Return Successd!",
                       @"result" : @{
                                     @"area":@"江苏省苏州市",
                                     @"location":@"电信"
                                     }
                       };

YFModel<IPResponse> *ipRes = [YFModel modelWithDict:dict];
NSLog(@"code : %@, area : %@", ipRes.code, ipRes.result.area);

------------

code : 200, area : 江苏省苏州市

```
