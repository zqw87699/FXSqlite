//
//  FXSqliteUtiles.h
//  TTTT
//
//  Created by 张大宗 on 2017/4/24.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,FXSqliteFieldType){
    /*
     *  整数型
     */
    FXSqliteFieldTypeInteger = 1,
    
    /*
     *  浮点型
     */
    FXSqliteFieldTypeDouble = 2,
    
    /*
     *  字符型
     */
    FXSqliteFieldTypeString = 3,
    
    /*
     *  二进制型
     */
    FXSqliteFieldTypeBlob = 4,
    
    /*
     *  空
     */
    FXSqliteFieldTypeNull = 5,
};

@interface FXSqliteUtiles : NSObject

/*
 *  获取FxSqliteColumn类字段
 */
+ (NSArray*)getColumnField:(Class)clazz;

+ (FXSqliteFieldType)matchValueType:(id)value;

@end
