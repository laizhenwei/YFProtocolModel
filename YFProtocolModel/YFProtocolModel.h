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

@protocol YFProtocolModel <NSObject>
@property (nonatomic, strong, readonly) Protocol *protocol;
@end

/**
 创建 Protocol Model
 
 @params protocol   协议
 @params json       jsonString, jsonData, dict, array
 */
__attribute__((overloadable)) extern id YFProtocolModelCreate(Protocol *protocol, id json);
__attribute__((overloadable)) extern id YFProtocolModelCreate(Protocol *protocol);


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
- (void)yf_protocol_model_set_ ## _struct_:(_struct_)arg forKey:(NSString *)key;    \
- (_struct_)yf_protocol_model_get_ ## _struct_ ## ForKey:(NSString *)key;           \
@end                                                                                \
@implementation NSMutableDictionary (YFProtocol_ ## _struct_ ## _Support)           \
- (void)yf_protocol_model_set_ ## _struct_:(_struct_)arg forKey:(NSString *)key {   \
    NSValue *val = [NSValue value:&arg withObjCType:@encode(_struct_)];             \
    [self setValue:val forKey:key];                                                 \
}                                                                                   \
- (_struct_)yf_protocol_model_get_ ## _struct_ ## ForKey:(NSString *)key {          \
    NSValue *val = [self valueForKey:key];                                          \
    _struct_ ret;                                                                   \
    [val getValue:&ret];                                                            \
    return ret;                                                                     \
}                                                                                   \
@end

