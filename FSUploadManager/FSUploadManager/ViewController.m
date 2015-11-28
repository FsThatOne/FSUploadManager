//
//  ViewController.m
//  FSUploadManager
//
//  Created by FS小一 on 15/7/28.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//

#import "ViewController.h"
#import "FSUploadManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    // AFN 不支持多文件上传! 多文件上传使用自己写的框架!

    // 实例化上传管理者对象
    FSUploadManager* mgr = [FSUploadManager sharedManager];

    // key :文件名 value:路径
    NSString* name1 = @"很好看的图片";
    NSString* path1 = @"/Users/apple/Desktop/12345.png";

    NSString* name2 = @"很难懂的格式";
    NSString* path2 = @"/Users/apple/Desktop/vedios.json";

    NSString* name3 = @"很有用的资料";
    NSString* path3 = @"/Users/apple/Desktop/Xcode7";

    NSDictionary* fileDict = @{ name1 : path1, name2 : path2, name3 : path3 };
    NSDictionary* paramater = @{ @"username" : @"HM",
        @"password" : @"HMHM" };

    // 上传文件
    [mgr UploadFileWithUrlString:@"http://localhost/upload/upload-m.php" FileDict:fileDict fileKey:@"userfile[]" paramater:paramater];
}
@end
