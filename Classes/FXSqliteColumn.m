//
//  FXSqliteColumn.m
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import "FXSqliteColumn.h"

@implementation FXSqliteColumn

- (instancetype)init{
    self = [super init];
    if (self) {
        self.fieldDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addField:(FXSqliteField *)field{
    [self.fieldDict setObject:field forKey:field.name];
}

@end
