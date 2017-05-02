//
//  FXSqliteConfig.m
//  TTTT
//
//  Created by 张大宗 on 2017/4/27.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import "FXSqliteConfig.h"

@implementation FXSqliteConfig

DEF_SINGLETON_INIT(FXSqliteConfig)

- (void)singleInit{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.dbName = [infoDictionary objectForKey:(NSString *)kCFBundleExecutableKey]; //项目名称
    self.dbName = [self.dbName stringByAppendingString:@".db"];
    //NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];// app名称
    self.dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
}

- (NSString*)sqlitePath{
    return [self.dbPath stringByAppendingString:[NSString stringWithFormat:@"/%@",self.dbName]];
}

@end
