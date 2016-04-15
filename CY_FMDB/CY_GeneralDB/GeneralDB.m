//
//  GeneralDB.m
//  ScrollViewDemo
//
//  Created by Evan on 15/12/11.
//  Copyright © 2015年 Fai. All rights reserved.
//

#import "GeneralDB.h"
#import "FMDB.h"

@interface GeneralDB () 

@end

@implementation GeneralDB
@synthesize dataBaseName;

// 把userDB设计成一个单例类
+ (id)shareInstance {
    static GeneralDB* instnce = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        instnce = [[self alloc] init];
    });
    
    return instnce;
}

- (NSString *)getBasePath {
    
    if (!dataBaseName || [dataBaseName isEqualToString:@""] || [dataBaseName isEqualToString:[self getBundleName]]) {
        
        dataBaseName = [self getBundleName];
        NSString *basePath = [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:dataBaseName];
        // 文件路径
            NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",dataBaseName];
            NSLog(@"文件路径 == %@",filePath);
        return basePath;
    }
    
    // 读取拖拽数据
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dataBaseName];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dataBaseName];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    return writableDBPath;
}

// 获取包名做数据库名称
- (NSString *)getBundleName {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [infoDict objectForKey:@"CFBundleName"];
    return [bundleName stringByAppendingString:@".sqlite"];
}

// 创建项目表
- (NSInteger)createTable:(NSString*)sql tableName:(NSString*)tableName{
    NSInteger flag = 0;
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getBasePath]];
    
    if ([db open]) {
        [db executeUpdate:@"PRAGMA foreign_keys=ON;"];
        if (![db tableExists:tableName]) {
            if ([db executeUpdate:sql]) {
            }else{;
                flag = -1;
            }
        } else {
        }
    } else{
        flag = -2;
    }
    [db close];
    return flag;
}

- (BOOL)tableExists:(NSString*)tableName{
    FMDatabase *db = [FMDatabase databaseWithPath:[self getBasePath]];
    if ([db open]) {
        if(![db tableExists:tableName]){
            [db close];
            return false;
        }
    }
    [db close];
    return true;
}

- (NSMutableArray*) getTableData:(NSString*)sql, ...{
    va_list args;
    va_start(args,sql);
    NSMutableArray* dataList = [NSMutableArray array];
    
    // 文件路径
    //    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",dataBaseName];
    //    NSLog(@"文件路径 == %@",filePath);
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getBasePath]];
    if ([db open]) {
        FMResultSet* results = [db executeQuery:sql withVAList:args];
        while (results.next) {
            [dataList addObject:[results resultDictionary]];
        }
        [results close];
    }
    va_end(args);
    [db close];
    return dataList;
}


- (BOOL)dataExists:(NSString*)sql, ...{
    va_list args;
    va_start(args, sql);
    NSInteger flag = true;
    FMDatabase* db = [FMDatabase databaseWithPath:[self getBasePath]];
    if([db open]){
        FMResultSet* results = [db executeQuery:sql withVAList:args];
        while (results.next) {
            if([results intForColumnIndex:0] == 0){
                flag = false;
            }
        }
        [results close];
    }
    va_end(args);
    [db close];
    return flag;
}

- (BOOL)insertTableData:(NSString*)sql, ...{
    BOOL flag = true;
    va_list args;
    va_start(args, sql);
    FMDatabase* db = [FMDatabase databaseWithPath:[self getBasePath]];
    if([db open]){
        flag = [db executeUpdate:sql withVAList:args];
    }
    va_end(args);
    [db close];
    return flag;
}

- (BOOL)updateTableData:(NSString*)sql, ...{
    BOOL flag = true;
    va_list args;
    va_start(args, sql);
    FMDatabase* db = [FMDatabase databaseWithPath:[self getBasePath]];
    if([db open]){
        flag = [db executeUpdate:sql withVAList:args];
    }
    va_end(args);
    return flag;
}

- (BOOL)deleteTableData:(NSString*)sql, ...{
    BOOL flag = true;
    va_list args;
    va_start(args, sql);
    FMDatabase* db = [FMDatabase databaseWithPath:[self getBasePath]];
    if([db open]){
        [db executeUpdate:@"PRAGMA foreign_keys=ON;"];
        flag = [db executeUpdate:sql withVAList:args];
    }
    va_end(args);
    [db close];
    return flag;
}

@end
