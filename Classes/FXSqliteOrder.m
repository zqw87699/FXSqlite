//
//  FXSqliteOrder.m
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import "FXSqliteOrder.h"
#import "FXSqliteConfig.h"
#import "FXLogMacros.h"
#import "FXSqliteColumn.h"
#import "FXSqliteUtiles.h"
#import "FXJsonUtiles.h"

@interface FXSqliteOrder()

@property (nonatomic, assign) sqlite3 *pDB;

@property (nonatomic, assign) sqlite3_stmt*stmt;

@end

@implementation FXSqliteOrder

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString*path = [[FXSqliteConfig sharedInstance] sqlitePath];
        FXLogDebug(@"%@",path);
        sqlite3_initialize();

        int result = sqlite3_open(path.UTF8String,&self->_pDB);
        if (result != SQLITE_OK) {
            FXLogError(@"打开数据库失败，错误码:%d" , result);
            sqlite3_close(self.pDB);
            sqlite3_shutdown();
            sqlite3_open(path.UTF8String,&self->_pDB);
        }
    }
    return self;
}

- (BOOL)createTable:(Class)column{
    if (![self existTable:column]) {
        NSArray *allFields = [FXSqliteUtiles getColumnField:column];
        NSString *sql =  [NSString stringWithFormat:@"create table if not exists %@(ID integer primary key autoincrement",NSStringFromClass(column)];
        for (FXSqliteField *field in allFields) {
            switch (field.type) {
                case FXSqliteFieldTypeString:{
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@",%@ ntext",field.name]];
                    break;
                }
                case FXSqliteFieldTypeInteger:{
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@",%@ integer",field.name]];
                    break;
                }
                case FXSqliteFieldTypeDouble:{
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@",%@ double",field.name]];
                    break;
                }
                case FXSqliteFieldTypeBlob:{
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@",%@ blob",field.name]];
                    break;
                }
                default:
                    break;
            }
        }
        sql = [sql stringByAppendingString:@")"];
        FXLogDebug(@"建表SQL:%@",sql);
        return [self execSql:sql] == SQLITE_OK;
    }
    return NO;
}

- (BOOL)alterTableClass:(Class)column{
    char** pResult;
    int nCol;
    NSString *sql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",NSStringFromClass(column)];
    int result = sqlite3_get_table(_pDB, [sql UTF8String], &pResult, NULL, &nCol, NULL);
    if (result != SQLITE_OK) {
        sqlite3_free_table(pResult);
        return [self createTable:column];
    }else{
        NSArray *allFields = [FXSqliteUtiles getColumnField:column];
        for (FXSqliteField *field in allFields) {
            BOOL alter = true;
            for (int i=0; i<nCol; i++) {
                if (FX_STRING_EQUAL(field.name, [NSString stringWithUTF8String:pResult[i]])) {
                    alter = false;
                    break;
                }
            }
            NSString*alterSql =[NSString stringWithFormat:@"alter table '%@' add '%@' ",NSStringFromClass(column),field.name];
            switch (field.type) {
                case FXSqliteFieldTypeString:{
                    alterSql = [alterSql stringByAppendingString:[NSString stringWithFormat:@"%@ ntext",field.name]];
                    break;
                }
                case FXSqliteFieldTypeInteger:{
                    alterSql = [alterSql stringByAppendingString:[NSString stringWithFormat:@"%@ integer",field.name]];
                    break;
                }
                case FXSqliteFieldTypeDouble:{
                    alterSql = [alterSql stringByAppendingString:[NSString stringWithFormat:@"%@ double",field.name]];
                    break;
                }
                case FXSqliteFieldTypeBlob:{
                    alterSql = [alterSql stringByAppendingString:[NSString stringWithFormat:@"%@ blob",field.name]];
                    break;
                }
                default:
                    break;
            }
            if ([self execSql:alterSql] != SQLITE_OK){
                FXLogError(@"添加字段%@失败",field.name);
            };
        }
    }
    return true;
}

- (int)execSql:(NSString *)sql{
    char *err;
    int result = sqlite3_exec(_pDB, [sql UTF8String], NULL, NULL, &err);
    if (err) {
        FXLogError(@"%s",err);
    }
    sqlite3_free(err);
    return result;
}

- (BOOL)affairExecSql:(NSArray<NSString *> *)sql{
    char * errMsg = NULL;
    int result;
    
    result = sqlite3_exec(_pDB, "begin;",NULL,NULL, &errMsg); //开启事务
    if (result != SQLITE_OK) {
        FXLogError(@"开启事务失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
        return NO;
    }
    for (int i = 0; i<sql.count; i++) {
        NSString*ssql = [sql objectAtIndex:i];
        result = sqlite3_exec(_pDB,[ssql UTF8String],NULL,NULL,&errMsg);
        if(result != SQLITE_OK ){
            FXLogError(@"执行SQL失败:%@,错误码:%d,错误原因:%s\n",sql,result, errMsg );
            return NO;
        }
    }
    
    result = sqlite3_exec(_pDB, "commit;", NULL, NULL, &errMsg);
    if (result != SQLITE_OK) {
        FXLogError(@"提交数据失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
        return NO;
    }
    return YES;
}

- (BOOL)existTable:(Class)clazz{
    if (!(clazz == [FXSqliteColumn class] || [clazz isSubclassOfClass:[FXSqliteColumn class]])){
        FXLogError(@"%@未继承FXSqliteColumn",NSStringFromClass(clazz));
        return NO;
    }else{
        NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name='%@'",NSStringFromClass(clazz)];
        FXLogDebug(@"%@",sql);
        return [self execSql:sql];
    }
}

- (BOOL)insertData:(FXSqliteColumn*)column{
    NSArray *allFields = [FXSqliteUtiles getColumnField:[column class]];
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (",[column class]];
    NSString *sqlValue = @" values(";
    for (int i=0;i<allFields.count;i++) {
        FXSqliteField *field = allFields[i];
        if(i>0) {
            sql = [sql stringByAppendingString:@","];
            sqlValue = [sqlValue stringByAppendingString:@","];
        }
        sql = [sql stringByAppendingString:field.name];
        sqlValue = [sqlValue stringByAppendingString:[NSString stringWithFormat:@":%@",field.name]];
    }
    sql = [sql stringByAppendingString:@")"];
    sqlValue = [sqlValue stringByAppendingString:@")"];
    sql = [sql stringByAppendingString:sqlValue];
    FXLogDebug(@"Insert SQL:%@",sql);
    NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
    for (FXSqliteField *field in allFields) {
        if ([column valueForKey:field.name]) {
            [valueDict setObject:[column valueForKey:field.name] forKey:field.name];
        }
    }
    NSArray *result = [self prepareSql:sql BindParams:valueDict];
    if (result) {
        return YES;
    }
    return NO;
}

- (NSArray<FXSqliteColumn*>*)prepareSql:(NSString *)sql BindParamArray:(NSArray *)params{
    int result = sqlite3_prepare_v2(_pDB, [sql UTF8String], -1, &_stmt, NULL);
    if (result == SQLITE_OK) {
        if (params && params.count>=sqlite3_bind_parameter_count(_stmt)) {
            FXLogDebug(@"%d",sqlite3_bind_parameter_count(_stmt));
            for (int i=0;i<sqlite3_bind_parameter_count(_stmt);i++) {
                id value = [[params objectAtIndex:i] copy];
                FXSqliteFieldType type = [FXSqliteUtiles matchValueType:value];
                switch (type) {
                    case FXSqliteFieldTypeString:{
                        sqlite3_bind_text(_stmt, i+1, [value UTF8String], -1, SQLITE_STATIC);
                        break;
                    }
                    case FXSqliteFieldTypeInteger:{
                        sqlite3_bind_int(_stmt, i+1, [value intValue]);
                        break;
                    }
                    case FXSqliteFieldTypeDouble:{
                        sqlite3_bind_double(_stmt, i+1, [value doubleValue]);
                        break;
                    }
                    case FXSqliteFieldTypeBlob:{
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
                        sqlite3_bind_blob(_stmt, i+1, data.bytes, (int)data.length, SQLITE_STATIC);
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        NSMutableArray *array = [[NSMutableArray alloc] init];
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            FXSqliteColumn *column = [[FXSqliteColumn alloc] init];
            for(int i=0;i<sqlite3_column_count(_stmt);i++){
                FXSqliteField *field = [[FXSqliteField alloc] initWithSqlite:_stmt FieldId:i];
                [column addField:field];
            }
            [array addObject:column];
        }
        sqlite3_finalize(_stmt);
        return array;
    }else{
        sqlite3_finalize(_stmt);
        FXLogDebug(@"[Array] SQL:%@执行失败  状态:%d",sql,result);
        return nil;
    }
}

- (NSArray<FXSqliteColumn*>*)prepareSql:(NSString *)sql BindParams:(NSDictionary *)params{
    int result = sqlite3_prepare_v2(_pDB, [sql UTF8String], -1, &_stmt, NULL);
    if (result == SQLITE_OK) {
        if (params) {
            for (int i=0;i<sqlite3_bind_parameter_count(_stmt);i++) {
                const char *name = sqlite3_bind_parameter_name(_stmt, i+1);
                if (!name || ![params objectForKey:[[NSString stringWithUTF8String:name] stringByReplacingOccurrencesOfString:@":" withString:@""]]) {
                    continue;
                }
                id value = [[params objectForKey:[[NSString stringWithUTF8String:name] stringByReplacingOccurrencesOfString:@":" withString:@""]] copy];
                FXSqliteFieldType type = [FXSqliteUtiles matchValueType:value];
                switch (type) {
                    case FXSqliteFieldTypeString:{
                        sqlite3_bind_text(_stmt, i+1, [value UTF8String], -1, SQLITE_STATIC);
                        break;
                    }
                    case FXSqliteFieldTypeInteger:{
                        sqlite3_bind_int(_stmt, i+1, [value intValue]);
                        break;
                    }
                    case FXSqliteFieldTypeDouble:{
                        sqlite3_bind_double(_stmt, i+1, [value doubleValue]);
                        break;
                    }
                    case FXSqliteFieldTypeBlob:{
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
                        sqlite3_bind_blob(_stmt, i+1, data.bytes, (int)data.length, SQLITE_STATIC);
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        NSMutableArray *array = [[NSMutableArray alloc] init];
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            FXSqliteColumn *column = [[FXSqliteColumn alloc] init];
            for(int i=0;i<sqlite3_column_count(_stmt);i++){
                FXSqliteField *field = [[FXSqliteField alloc] initWithSqlite:_stmt FieldId:i];
                [column addField:field];
            }
            [array addObject:column];
        }
        sqlite3_finalize(_stmt);
        return array;
    }else{
        sqlite3_finalize(_stmt);
        FXLogDebug(@"[Dict] SQL:%@执行失败  状态:%d",sql,result);
        return nil;
    }
}

- (NSInteger)lastInsertRowid{
    return sqlite3_last_insert_rowid(_pDB);
}

- (void)closeDB{
    sqlite3_close(_pDB);
    sqlite3_shutdown();
}

@end
