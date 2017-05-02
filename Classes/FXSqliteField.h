//
//  FXSqliteField.h
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FXSqliteUtiles.h"

@interface FXSqliteField : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) FXSqliteFieldType type;

@property (nonatomic, strong) id value;

- (instancetype) initWithName:(NSString*)name Type:(FXSqliteFieldType)type Value:(id)value;

- (instancetype) initWithSqlite:(sqlite3_stmt*)stmt FieldId:(int)fid;

@end
