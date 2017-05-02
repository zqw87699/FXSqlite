//
//  FXSqliteConfig.h
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <FXCommon/FXCommon.h>

@interface FXSqliteConfig : NSObject

AS_SINGLETON(FXSqliteConfig)

/*
 *  数据库名称
 *  default:当前项目名称.db
 */
@property (nonatomic, strong) NSString *dbName;

/*
 *  数据库路径
 *  default:沙盒Documents路径
 */
@property (nonatomic, strong) NSString *dbPath;

- (NSString*)sqlitePath;

@end
