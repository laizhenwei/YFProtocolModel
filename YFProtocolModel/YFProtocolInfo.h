//
//  YFProtocolInfo.h
//  YFProtocolModel
//
//  Created by laizw on 2018/2/6.
//  Copyright © 2018年 laizw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, YFPropertyEncodeType) {
    YFPropertyEncodeTypeUnknown     = 0,
    YFPropertyEncodeTypeVoid        = 1, ///< void
    YFPropertyEncodeTypeBool        = 2, ///< bool
    YFPropertyEncodeTypeInt8        = 3, ///< char / BOOL
    YFPropertyEncodeTypeUInt8       = 4, ///< unsigned char
    YFPropertyEncodeTypeInt16       = 5, ///< short
    YFPropertyEncodeTypeUInt16      = 6, ///< unsigned short
    YFPropertyEncodeTypeInt32       = 7, ///< int
    YFPropertyEncodeTypeUInt32      = 8, ///< unsigned int
    YFPropertyEncodeTypeInt64       = 9, ///< long long
    YFPropertyEncodeTypeUInt64      = 10, ///< unsigned long long
    YFPropertyEncodeTypeFloat       = 11, ///< float
    YFPropertyEncodeTypeDouble      = 12, ///< double
    YFPropertyEncodeTypeLongDouble  = 13, ///< long double
    YFPropertyEncodeTypeObject      = 14, ///< id
    YFPropertyEncodeTypeClass       = 15, ///< Class
    YFPropertyEncodeTypeSEL         = 16, ///< SEL
    YFPropertyEncodeTypeBlock       = 17, ///< block
    YFPropertyEncodeTypePointer     = 18, ///< void*
    YFPropertyEncodeTypeStruct      = 19, ///< struct
    YFPropertyEncodeTypeUnion       = 20, ///< union
    YFPropertyEncodeTypeCString     = 21, ///< char*
    YFPropertyEncodeTypeCArray      = 22, ///< char[10] (for example)
};

typedef NS_OPTIONS(NSUInteger, YFPropertyFlag) {
    YFPropertyFlagUnknow    = 1 << 0,
    YFPropertyFlagCustomSetter  = 1 << 1,
    YFPropertyFlagCustomGetter  = 1 << 2,
    YFPropertyFlagReadonly      = 1 << 3,
    
    YFPropertyFlagProtocolType  = 1 << 4,
    YFPropertyFlagOjectType     = 1 << 5,
    YFPropertyFlagStructType    = 1 << 6,
    YFPropertyFlagNumberType    = 1 << 7,
    
};

@interface YFPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;

@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *structType;

@property (nonatomic, assign, readonly) YFPropertyFlag flag;
@property (nonatomic, assign, readonly) YFPropertyEncodeType encodeType;

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy, readonly) NSArray<NSString *> *generics;

@property (nonatomic, assign, readonly) SEL setter;
@property (nonatomic, assign, readonly) SEL getter;

- (instancetype)initWithProperty:(objc_property_t)property;
@end

@interface YFProtocolInfo : NSObject

@property (nonatomic, assign, readonly) Protocol *protocol;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray<YFPropertyInfo *> *properties;

+ (instancetype)infoWithProtocol:(Protocol *)protocol;
@end;
