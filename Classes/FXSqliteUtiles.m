//
//  FXSqliteUtiles.m
//  TTTT
//
//  Created by 张大宗 on 2017/4/24.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import "FXSqliteUtiles.h"
#import "FXJsonUtiles.h"
#import "FXLogMacros.h"
#import "FXStringUtiles.h"
#import <objc/runtime.h>
#import "FXSqliteColumn.h"

//忽略属性名称列表
static NSSet *ignorePropertyNames = nil;

@implementation FXSqliteUtiles

+ (void)load{
    ignorePropertyNames = [[NSSet alloc] initWithObjects:@"superclass",@"hash",@"debugDescription",@"description", nil];
}

+ (NSArray*)getColumnField:(Class)clazz{
    if (!(clazz == [FXSqliteColumn class] || [clazz isSubclassOfClass:[FXSqliteColumn class]])) {
        FXLogError(@"类%@未继承FXSqliteColumn",NSStringFromClass(clazz));
        return nil;
    }
    unsigned int count = 0;
    //获取属性的列表
    objc_property_t *propertyList =  class_copyPropertyList([clazz class], &count);
    NSMutableArray *fieldArray = [[NSMutableArray alloc] init];
    for(int i=0;i<count;i++)
    {
        //取出每一个属性
        objc_property_t property = propertyList[i];
        const char *attributes = property_getAttributes(property);
        
        NSString *attributeStr = [[NSString alloc] initWithBytes:attributes length:strlen(attributes) encoding:NSUTF8StringEncoding];
        NSString *a1 = [[[attributeStr componentsSeparatedByString:@","] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *typeName = nil;
        
        FXSqliteField *field = [[FXSqliteField alloc] init];
        field.name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([ignorePropertyNames containsObject:field.name]) {
            continue;
        }
        if ([a1 hasPrefix:@"T@"]) {
            typeName = [[NSString alloc] initWithString:[a1 substringWithRange:NSMakeRange(2, a1.length-2)]];
            if (FX_STRING_EQUAL(typeName, @"NSString") || FX_STRING_EQUAL(typeName, @"NSMutableString")) {
                field.type = FXSqliteFieldTypeString;
            }else{
                field.type = FXSqliteFieldTypeBlob;
            }
        } else {
            if (a1.length >= 2) {
                typeName = [a1 substringWithRange:NSMakeRange(1, a1.length-1)];
                if (strcmp(typeName.UTF8String, @encode(int)) == 0 || strcmp(typeName.UTF8String, @encode(long)) == 0) {
                    field.type = FXSqliteFieldTypeInteger;
                }else if (strcmp(typeName.UTF8String, @encode(float)) == 0 || strcmp(typeName.UTF8String, @encode(double)) == 0){
                    field.type = FXSqliteFieldTypeDouble;
                }else{
                    field.type = FXSqliteFieldTypeBlob;
                }
            }
        }
        [fieldArray addObject:field];
    }
    //c语言的函数，所以要去手动的去释放内存
    free(propertyList);
    return [fieldArray copy];
}


+ (FXSqliteFieldType)matchValueType:(id)value{
    if([value isKindOfClass:[NSNumber class]])
    {
        if (strcmp([value objCType], @encode(float)) == 0 || strcmp([value objCType], @encode(double)) == 0)
        {
            return FXSqliteFieldTypeDouble;
        }else{
            return FXSqliteFieldTypeInteger;
        }
    }else if ([value isKindOfClass:[NSString class]]){
        return FXSqliteFieldTypeString;
    }else if ((NSNull*)value == [NSNull null] || value == nil || [value isKindOfClass:[NSNull class]]){
        return FXSqliteFieldTypeNull;
    }else{
        return FXSqliteFieldTypeBlob;
    }
}

@end
