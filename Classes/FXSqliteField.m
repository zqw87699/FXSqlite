//
//  FXSqliteField.m
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import "FXSqliteField.h"
#import "FXJsonUtiles.h"

@implementation FXSqliteField

- (instancetype)initWithName:(NSString *)name Type:(FXSqliteFieldType)type Value:(id)value{
    self = [super init];
    if (self) {
        self.name = name;
        self.value = value;
        self.type = [FXSqliteUtiles matchValueType:value];
    }
    return self;
}

- (instancetype)initWithSqlite:(sqlite3_stmt *)stmt FieldId:(int)fid{
    self = [super init];
    if (self) {
        self.name = [NSString stringWithUTF8String:sqlite3_column_name(stmt, fid)];
        self.type = sqlite3_column_type(stmt, fid);
        switch (self.type) {
            case FXSqliteFieldTypeDouble:{
                self.value = @(sqlite3_column_double(stmt, fid));
                break;
            }
            case FXSqliteFieldTypeInteger:{
                self.value = @(sqlite3_column_int(stmt, fid));
                break;
            }
            case FXSqliteFieldTypeString:{
                self.value = [NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, fid)];
                break;
            }
            case FXSqliteFieldTypeBlob:{
                NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, fid) length:sqlite3_column_bytes(stmt, fid)];
                self.value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                break;
            }
            default:
                break;
        }
    }
    return self;
}


@end
