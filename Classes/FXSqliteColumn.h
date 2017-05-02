//
//  FXSqliteColumn.h
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXSqliteField.h"
#import "BaseFXObject.h"

@interface FXSqliteColumn : BaseFXObject

@property (nonatomic, strong) NSMutableDictionary<NSString*,FXSqliteField*> *fieldDict;

- (instancetype) init;

- (void)addField:(FXSqliteField*)field;

@end
