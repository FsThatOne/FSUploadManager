//
//  FSUploadManager.m
//  FSUploadManager
//
//  Created by FS小一 on 15/7/28.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//
#define kBoundary @"boundary"

#import "FSUploadManager.h"

@implementation FSUploadManager

- (void)UploadFileWithUrlString:(NSString*)urlString FileDict:(NSDictionary*)fileDict fileKey:(NSString*)fileKey paramater:(NSDictionary*)paramater
{
    // 1.创建请求
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求方法:
    request.HTTPMethod = @"POST";
    NSString* type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBoundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];

    // 设置请求体:
    request.HTTPBody = [self getHttpBodyWithFileDict:fileDict fileKey:fileKey paramater:paramater];

    // 2.发送请求
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                               //
                               NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                           }];
}

/**
 *  多文件 + 普通上传的格式封装
 *
 *  @param fileDict  文件参数字典: key:文件名; value:文件路径
 *  @param fileKey   服务器接收文件参数的 key 值, 这个 key 是后台人员告诉我们的!
 *  @param paramater 普通文本参数字典: key: 服务器接收普通参数的 key 值,也是后台人员告诉我们的! value: 需要上传当 普通参数.
 *
 *  @return 封装好的上传数据格式(POST请求体中的内容)
 */
- (NSData*)getHttpBodyWithFileDict:(NSDictionary*)fileDict fileKey:(NSString*)fileKey paramater:(NSDictionary*)paramater
{
    NSMutableData* data = [NSMutableData data];

    // fileDict 文件字典,
    // 遍历字典,封装数据!
    [fileDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        // filePath :文件路径!
        // fileName: 文件在服务器中保存的名称!
        NSString* filePath = obj;
        NSString* fileName = key;

        //上边界
        NSMutableString* headerStrM1 = [NSMutableString stringWithFormat:@"\r\n--%@\r\n", kBoundary];
        [headerStrM1 appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", fileKey, fileName];

        FSUploadManager* mgr = [FSUploadManager sharedManager];
        NSURLResponse* response = [mgr getFileTypeWithFilePath:filePath];
        [headerStrM1 appendFormat:@"Content-Type: %@\r\n\r\n", response.MIMEType];

        [data appendData:[headerStrM1 dataUsingEncoding:NSUTF8StringEncoding]];

        // 文件内容
        [data appendData:[NSData dataWithContentsOfFile:filePath]];
    }];

    // 比如: 后台服务器在接收普通参数(非文件参数,字符串)的时候,如果有key 值,应该怎么封装!
    // 添加非文件数据

    // 遍历非文件参数的字典,分别拼接
    [paramater enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {

        // key :服务器接收的 key  obj:需要上传给服务器的文字信息!
        NSMutableString* headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n", kBoundary];
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", key];

        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];

        // 拼接上传的文本信息.
        NSString* str = obj;
        [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    // 只有一个下边界
    // 下边界
    NSMutableString* footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--", kBoundary];
    [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];

    return data;
}

// 数据上传!
- (void)UploadFileWithUrlString:(NSString*)urlString filePath:(NSString*)filePath nameKey:(NSString*)filekey fileName:(NSString*)fileName
{
    // 1.创建请求
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求方法:
    request.HTTPMethod = @"POST";
    NSString* type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBoundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];

    // 设置请求体:
    request.HTTPBody = [self getHttpBodyWithFilePath:filePath nameKey:filekey fileName:fileName];

    // 2.发送请求
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError) {
                               //
                               NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                           }];
}

// 一般在定义单例的时候!
// 专门获取单例对象的方法!
// 如果想获取一个普通的对象!一般在定义单例对象的时候,没有必要把所有的路都堵死!
+ (instancetype)sharedManager
{
    static id _instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/**
 *  动态封装请求体中的内容(文件上传的格式)
 *
 *  @param filePath 需要上传的文件路径
 *  @param filekey  服务器接收文件的 key 值
 *  @param fileName 文件在服务器中保存的名称
 *
 *     return :封装好的上传数据
 */
- (NSData*)getHttpBodyWithFilePath:(NSString*)filePath nameKey:(NSString*)filekey fileName:(NSString*)fileName
{
    NSMutableData* data = [NSMutableData data];

    // 上边界
    NSMutableString* headerStrM = [NSMutableString stringWithFormat:@"--%@\r\n", kBoundary];

    NSURLResponse* response = [self getFileTypeWithFilePath:filePath];

    NSString* contentType = response.MIMEType;

    if (!fileName) { // 如果用户没有指定上传文件在服务器中保存的名称,就直接传一个 默认的名称!
        fileName = response.suggestedFilename;
    }
    [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", filekey, fileName];
    [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n", contentType];

    [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];

    [data appendData:[NSData dataWithContentsOfFile:filePath]];

    // 下边界
    NSMutableString* footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--", kBoundary];
    [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];

    return data;
}

// 动态的获取数据类型!
- (NSURLResponse*)getFileTypeWithFilePath:(NSString*)filePath
{
    // 发送一个本地请求,获得响应的 MIMEType 就是响应中的 Content-Type ,就是文件的类型!

    // 由于需要知道 文件类型之后,在做数据的封装,必须发送一个同步请求,来获取文件类型!

    // 1. 创建请求

    // 本地文件请求!
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", filePath]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];

    // 发送同步请求

    NSURLResponse* response = nil;
    // 看到 两个 ** 一般肯定是要传一个对象地址! 为了接收参数!
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];

    // response.MIMEType 就是文件的类型.
    // response 中可以返回很多有用的数据.
    // 在文件下载的时候,获取文件的大小!
    // suggestedFilename :建议的名称
    // NSLog(@"%@",response.suggestedFilename);
    return response;
}

@end
