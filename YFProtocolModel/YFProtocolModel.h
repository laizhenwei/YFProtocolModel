//
//  YFProtocolModel.h
//  YFProtocolModel
//
//  Created by laizw on 2018/2/6.
//  Copyright © 2018年 laizw. All rights reserved.
//

@import UIKit;

FOUNDATION_EXPORT double YFProtocolModelVersionNumber;
FOUNDATION_EXPORT const unsigned char YFProtocolModelVersionString[];

/**
  基础 Protocol，提供映射、KVO 等接口
 */
@protocol YFProtocolModel <NSObject>
@optional

@property (nonatomic, strong, readonly) Protocol *protocol;

// Transformer
+ (NSDictionary<NSString *, id> *)modelPropertyKeyMapper;

+ (NSDictionary<NSString *, Protocol *> *)modelContainerPropertyGenericProtocol;

// KVO Supports
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
@end

/**
 创建 Protocol Model
 
 @params protocol   协议
 @params json       jsonString, jsonData, dict, array
 */
__attribute__((overloadable)) extern id YFProtocolModelCreate(Protocol *protocol, id json);
__attribute__((overloadable)) extern id YFProtocolModelCreate(Protocol *protocol);


/**
 实现 JSON 和 Model 转换的相关协议方法
 
 eg.
 @protocol implementation(MyProtocol)
 + (NSDictionary<NSString *, id> *)modelPropertyKeyMapper {
    ...
 }
 @end
 */
#define implementation(_protocol_) _protocol_;                                      \
_Pragma("clang diagnostic push")                                                    \
_Pragma("clang diagnostic ignored \"-Wobjc-protocol-property-synthesis\"")          \
@interface __YFTransformer_ ## _protocol_ : NSObject <_protocol_, YFProtocolModel>  \
@end                                                                                \
@implementation __YFTransformer_ ## _protocol_                                      \
_Pragma("clang diagnostic pop")                                                     \


/**
 定义一个注册 struct 类型
 
 eg.
 YFProtocolDefineStruct(MyStruct, {
    int arg;
    // ...
 })
 */
#define YFProtocolDefineStruct(_name_, _body_) \
        typedef struct _name_ _body_ _name_; \
        YFProtocolRegisterStruct(_name_)


/*
 默认注册了一些常用的结构体
 
 YFProtocolRegisterStruct(CGRect)
 YFProtocolRegisterStruct(CGSize)
 YFProtocolRegisterStruct(CGPoint)
 YFProtocolRegisterStruct(NSRange)
 YFProtocolRegisterStruct(UIOffset)
 YFProtocolRegisterStruct(CGVector)
 YFProtocolRegisterStruct(UIEdgeInsets)
 YFProtocolRegisterStruct(CGAffineTransform)
 */

/**
 注册 Struct 使它支持 ProtocolModel 访问和赋值
 */
#define YFProtocolRegisterStruct(_struct_)                                          \
@interface NSMutableDictionary (YFProtocol_ ## _struct_ ## _Support)                \
- (void)set ## _struct_:(_struct_)arg forKey:(NSString *)key;                       \
- (_struct_)get ## _struct_ ## ForKey:(NSString *)key;                              \
@end                                                                                \
@implementation NSMutableDictionary (YFProtocol_ ## _struct_ ## _Support)           \
- (void)set ## _struct_:(_struct_)arg forKey:(NSString *)key {                      \
    NSValue *val = [NSValue value:&arg withObjCType:@encode(_struct_)];             \
    [self setValue:val forKey:key];                                                 \
}                                                                                   \
- (_struct_)get ## _struct_ ## ForKey:(NSString *)key {                             \
    NSValue *val = [self valueForKey:key];                                          \
    _struct_ ret;                                                                   \
    [val getValue:&ret];                                                            \
    return ret;                                                                     \
}                                                                                   \
@end

