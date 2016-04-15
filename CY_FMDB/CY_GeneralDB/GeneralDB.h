//
//  GeneralDB.h
//  ScrollViewDemo
//
//  Created by Evan on 15/12/11.
//  Copyright © 2015年 Fai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralDB : NSObject
/**
 单例模式
 */
+ (id)shareInstance;
/**
 * @brief   创建数据库
 * @param   sql 预处理语句
 * @param   表名
 * @return 0 成功 -1 数据库创建失败 -2 数据库打开失败
 */
- (NSInteger)createTable:(NSString*)sql tableName:(NSString*)tableName;

/**
 *  @brief  检查数据表是否存在
 *  @param  tableNmae 表名
 */
- (BOOL)tableExists:(NSString*)tableName;

/**
 *  @brief  判断数据是否存在 SELECT COUNT(*)
 *  @param  sql 预处理语句 stmt参数
 */
- (BOOL)dataExists:(NSString*)sql, ...;

/**
 *  @brief  获取数据表数据
 *  @param  sql 预处理语句 stmt参数  select count
 *  @return 返回NSDictionary成员的NSArray结果集
 */
- (NSMutableArray*) getTableData:(NSString*)sql, ...;

/**
 *  @brief 插入数据
 *  @param sql 预处理语句
 *  @return FALSE 插入失败
 */
- (BOOL)insertTableData:(NSString*)sql, ...;

/**
 *  @brief 更新数据
 *  @param sql 预处理语句
 */
- (BOOL)updateTableData:(NSString*)sql, ...;

/**
 *  @brief 删除数据
 *  @param sql 预处理语句

 */
- (BOOL)deleteTableData:(NSString*)sql, ...;

/**
 *  读取本地数据库的表名
 */
@property (copy, nonatomic) NSString *dataBaseName;

@end
