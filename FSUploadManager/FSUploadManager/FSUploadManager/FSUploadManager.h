//
//  FSUploadManager.h
//  FSUploadManager
//
//  Created by FS小一 on 15/7/28.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSUploadManager : NSObject

/**
 *  直接封装多文件上传
 *
 *  @param urlString 后台支持的脚本
 *  @param fileDict  文件参数字典: key:文件名; value:文件路径
 *  @param fileKey   服务器接收文件参数的 key 值, 这个 key 是后台人员告诉我们的!
 *  @param paramater 普通文本参数字典: key: 服务器接收普通参数的 key 值,也是后台人员告诉我们的! value: 需要上传当 普通参数.
 */
- (void)UploadFileWithUrlString:(NSString*)urlString FileDict:(NSDictionary*)fileDict fileKey:(NSString*)fileKey paramater:(NSDictionary*)paramater;

/**
 *  多文件 + 普通上传的格式封装
 *
 *  @param fileDict  文件参数字典: key:文件名; value:文件路径
 *  @param fileKey   服务器接收文件参数的 key 值, 这个 key 是后台人员告诉我们的!
 *  @param paramater 普通文本参数字典: key: 服务器接收普通参数的 key 值,也是后台人员告诉我们的! value: 需要上传当 普通参数.
 *
 *  @return 封装好的上传数据格式(POST请求体中的内容)
 */
- (NSData*)getHttpBodyWithFileDict:(NSDictionary*)fileDict fileKey:(NSString*)fileKey paramater:(NSDictionary*)paramater;

/**
 *  直接封装文件上传! 采用 POST 上传的方法!
 *
 *  @param filePath  文件路径
 *  @param filekey  服务器接收文件的 key 值
 *  @param fileName 上传文件在服务器中保存的名称:如果传nil ,就使用默认的名称!
 */
- (void)UploadFileWithUrlString:(NSString*)urlString filePath:(NSString*)filePath nameKey:(NSString*)filekey fileName:(NSString*)fileName;

// 工具类: 单例
+ (instancetype)sharedManager;

/**
 *  动态获取文件类型(响应)
 *
 *  @param filePath 文件路径
 *
 *  @return 响应头 NSURLResponse
 */
- (NSURLResponse*)getFileTypeWithFilePath:(NSString*)filePath;

/**
 *  封装上传数据
 *
 *  @param filePath 文件路径
 *  @param filekey  服务器接收文件的 key 值
 *  @param fileName 上传文件在服务器中保存的名称:如果传nil ,就使用默认的名称!
 *
 *  @return 封装好的上传数据(直接赋值给 POST 请求的请求体)
 */
- (NSData*)getHttpBodyWithFilePath:(NSString*)filePath nameKey:(NSString*)filekey fileName:(NSString*)fileName;

@end
