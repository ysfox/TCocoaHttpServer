//
//  AppDelegate.m
//  TCocoaHttpServer
//
//  Created by Ysfox on 15/10/17.
//  Copyright (c) 2015年 Ysfox. All rights reserved.
//
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "AppDelegate.h"
#import "HTTPServer.h"

@interface AppDelegate ()
/** 服务器对象 */
@property (nonatomic,strong) HTTPServer *httpServer;
@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //初始化日志
    [self setupDDLog];
    //开启服务器
    [self setupHttpsever];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self startServer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [_httpServer stop];
}


/** 设置DDLOG框架 */
- (void)setupDDLog{
    //添加日志器框架到 Apple System Logging (asl)这个可以在Console.app看见和Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]];           //这个是将日志打给苹果服务器，可以通过在Console.app
    [DDLog addLogger:[DDTTYLogger sharedInstance]];           //这个是将日志打印到控制台
    
    
    //日志的筛选，筛选规则是通过DDLogLevel来决定只显示那些日志
    //[DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelError]; 只显示错误日志的信息
    
    // 开启日志等级颜色
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    // 设置不同等级日志的颜色
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor yellowColor] backgroundColor:nil forFlag:DDLogFlagWarning];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whiteColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    
    //告诉应用多久保存一次日志文件
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    DDLogInfo(@"dir is %@", fileLogger.logFileManager.logsDirectory);
    
    
    DDLogError(@"错误信息");
    DDLogWarn(@"警告消息");
    DDLogInfo(@"提示信息");
    DDLogDebug(@"调试信息");
    DDLogVerbose(@"冗长信息");
}


/** 初始化http服务器 */
- (void)setupHttpsever{
    _httpServer = [[HTTPServer alloc]init];         //初始化服务器
    [_httpServer setType:@"_http._tcp."];           //设置服务器类型
    //获取网页地址
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"webset"];
    DDLogInfo(@"Setting document root: %@", webPath);
    [_httpServer setDocumentRoot:webPath];          //设置服务器根路径
    [_httpServer setPort:80];                    //设置端口
    [self startServer];
}

/** 开启服务器 */
- (void)startServer
{
    NSError *error;
    if ([_httpServer start:&error]){
        DDLogInfo(@"%@",[NSString stringWithFormat:@"Started HTTP Server\nhttp://%@:%hu", [_httpServer hostName], [_httpServer listeningPort]]);
    }else{
        DDLogError(@"Error Started HTTP Server:%@", error);
    }

}

@end
