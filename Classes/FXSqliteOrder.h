//
//  FXSqliteOrder.h
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXSqliteColumn.h"

@interface FXSqliteOrder : NSObject

- (instancetype)init;

/*
 *  根据FXSqliteColumn建表
 */
- (BOOL)createTable:(Class)column;

/*
 *  根据FXSqliteColumn添加字段
 */
- (BOOL)alterTableClass:(Class)column;

/*
 *  根据FXSqliteColumn插入数据
 */
- (BOOL)insertData:(FXSqliteColumn*)column;

/*
 *  执行sqlite3_prepare_v2
 *  Example : insert into TMGroup (title) values (:title)
 */
- (NSArray<FXSqliteColumn*>*)prepareSql:(NSString *)sql BindParams:(NSDictionary *)params;

/*
 *  执行sqlite3_prepare_v2
 *  Example : insert into TMGroup (title) values (?)
 */
- (NSArray<FXSqliteColumn*>*)prepareSql:(NSString *)sql BindParamArray:(NSArray *)params;

/*
 *  执行sqlite3_exec
 */
- (int)execSql:(NSString *)sql;

/*
 *  事务执行sqlite3_exec
 */
- (BOOL)affairExecSql:(NSArray<NSString*>*)sql;

/*
 *  最后一个插入数据的主键
 */
- (NSInteger)lastInsertRowid;

/*
 *  关闭数据库
 */
- (void)closeDB;

@end
