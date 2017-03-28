//
//  ModuleCapability.h
//  Common
//
//  Created by 黄磊 on 16/4/14.
//  Copyright © 2016年 Musjoy. All rights reserved.
//

#ifndef ModuleCapability_h
#define ModuleCapability_h

#ifdef __cplusplus
#define MJ_EXTERN_C_BEGIN  extern "C" {
#define MJ_EXTERN_C_END  }
#else
#define MJ_EXTERN_C_BEGIN
#define MJ_EXTERN_C_END
#endif

#ifdef __cplusplus
# define MJ_EXTERN extern "C" __attribute__((visibility("default")))
#else
# define MJ_EXTERN extern __attribute__((visibility("default")))
#endif


//######################################
#pragma mark - 常用函数
//######################################
// 字符串拼接
#define combine(x, y)   [(x) stringByAppendingString:(y)]
// 字符串长度获取
#define textSizeWithFont(text, font) ([text length] > 0 ? [text sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero);
#define multilineTextSize(text, font, maxSize) ([text length] > 0 ? \
[text boundingRectWithSize:maxSize \
options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} \
context:nil].size : CGSizeZero);


//######################################
#pragma mark - 用户自定义常量导入
//######################################
#if __has_include("Constant.h")
#import "Constant.h"
#endif

//######################################
#pragma mark - 部分常量定义
//######################################
// 公开版本号。eg：1.0
#define kClientVersionShort [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
// 内部版本号。eg：1.0.1
#define kClientVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
// App Store
#ifndef kAppID
#define kAppID   @"unknown"
#ifdef IN_PROJECT
#ifdef DEBUG
#warning    @"App id is not defined!"
#else
#error      @"App id is not defined!"
#endif
#endif
#endif
#define kAppLookUpUrl    combine(@"http://itunes.apple.com/lookup?id=", kAppID)
#define kAppDownload     combine(@"http://itunes.apple.com/app/id", kAppID)
#define kAppComment      combine(combine(@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=", kAppID), @"&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
// 当前iOS版本
#define __CUR_IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue] * 10000)
// 屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
// 屏幕宽度
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

//######################################
#pragma mark - 常量默认值
//######################################
/** 默认动画持续时间 */
#ifndef DEFAULT_ANIMATE_DURATION
#define DEFAULT_ANIMATE_DURATION 0.3
#endif

//######################################
#pragma mark - Logging配置
//######################################
#ifndef LOGGING_CONFIG_BY_USER
#ifdef DEBUG
// TRACE CONFIG
#define LOGGING_ENABLED 1
#define LOGGING_INCLUDE_CODE_LOCATION 1
#define LOGGING_LEVEL_INFO 1
// FILE LOGGING
//#define LOGGING_TO_FILE
#endif
#endif
#import "Logging.h"

//######################################
#pragma mark - 高级函数
//######################################
// Json 解析
#ifdef MODULE_DB_MODEL
#define HEADER_MODEL        "DBModel.h"
#define MODEL_BASE_CLASS    DBModel
#define objectFromString(str, err) [DBModel objectFromJSONString:str error:err]
#else
#define HEADER_MODEL        <Foundation/Foundation.h>
#define MODEL_BASE_CLASS    NSObject
#define objectFromString(str, err) ({       \
    id aNil = nil;                          \
    id obj = aNil;                          \
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];            \
    if (data) {                             \
        NSError *initError = aNil;          \
        @try {                              \
            obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&initError];   \
        } @catch (NSException *exception) { \
            obj = aNil;                     \
        }                                   \
    }                                       \
    obj;                                    \
})
#endif
// Parse json
#ifdef MODULE_UTILS
#define jsonStringFromDic(aDic) [aDic convertToJsonString]
#else
#define jsonStringFromDic(aDic) ({          \
    NSData* jsonData = nil;                 \
    NSError* jsonError = nil;               \
    @try {                                  \
        jsonData = [NSJSONSerialization dataWithJSONObject:aDic             \
                                                   options:kNilOptions      \
                                                     error:&jsonError];     \
    } @catch (NSException *exception) {     \
        jsonData = nil;                     \
    }                                       \
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]; \
})
#endif


//######################################
#pragma mark - 服务器URL
//######################################
#ifndef HEADER_SERVER_URL
#define HEADER_SERVER_URL <Foundation/Foundation.h>
#endif


//######################################
#pragma mark - 统计分析模块
//######################################
#ifndef DEBUG
#if __has_include(<UMMobClick/MobClick.h>)
#define HEADER_ANALYSE <UMMobClick/MobClick.h>
#define triggerEventStr(eventId, evenDesc) [MobClick event:eventId attributes:@{@"name":evenDesc}]
#define triggerEvent(eventId, attrs) [MobClick event:eventId attributes:attrs]
#define triggerBeginPage(className) [MobClick beginLogPageView:className]
#define triggerEndPage(className) [MobClick endLogPageView:className]
#endif
#endif
#ifndef triggerEventStr
#define triggerEventStr(eventId, evenDesc) NSLog(@"Event trigger : %@", evenDesc)
#define triggerEvent(eventId, attrs) NSLog(@"Event trigger : %@", attrs)
#define triggerBeginPage(className) NSLog(@"Page begin : %@", className)
#define triggerEndPage(className) NSLog(@"Page end : %@", className)
#endif
/// 对应通用统计事件定义
#ifndef STAT_Error
#define STAT_Error      @"Error"
#endif


//######################################
#pragma mark - FileSource
//######################################
#ifdef MODULE_FILE_SOURCE
#define getFileData(aFileName) [FileSource dataWithFileName:aFileName]
#define getPlistFileData(aPlistName) [FileSource dataWithPlistName:aPlistName]
#define getJsonFileData(aJsonName) [FileSource dataWithJsonName:aJsonName]
#else
#define getPlistFileData(aPlistName) ({ \
    NSString *fileName = [aPlistName stringByAppendingString:@".plist"]; \
    NSString *fileBundle = [[NSBundle mainBundle] resourcePath]; \
    NSString *filePath = [fileBundle stringByAppendingPathComponent:fileName]; \
    NSDictionary *aDic = [[NSDictionary alloc] initWithContentsOfFile:filePath]; \
    aDic; \
})
#define getJsonFileData(aJsonName) ({ \
    NSString *fileName = [aJsonName stringByAppendingString:@".json"]; \
    NSString *fileBundle = [[NSBundle mainBundle] resourcePath]; \
    NSString *filePath = [fileBundle stringByAppendingPathComponent:fileName]; \
    NSData *data=[NSData dataWithContentsOfFile:filePath];             \
    id aNil = nil;  \
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data          \
                                                  options:NSJSONReadingAllowFragments   \
                                                    error:nil];          \
    jsonObject; \
})
#define getFileData(aFileName) getPlistFileData(aFileName)
#endif

//######################################
#pragma mark - ControllerManager
//######################################
// BaseViewController
#if __has_include("BaseViewController.h")
#define HEADER_BASE_VIEW_CONTROLLER "BaseViewController.h"
#define THEBaseViewController       BaseViewController
#elif (defined(MODULE_CONTROLLER_MANAGER) || __has_include("MJBaseViewController.h"))
#define HEADER_BASE_VIEW_CONTROLLER "MJBaseViewController.h"
#define THEBaseViewController       MJBaseViewController
#else
#define HEADER_BASE_VIEW_CONTROLLER <UIKit/UIKit.h>
#define THEBaseViewController       UIViewController
#endif
// NavigationController
#if __has_include("NavigationController.h")
#define HEADER_NAVIGATION_CONTROLLER    "NavigationController.h"
#define THENavigationController         NavigationController
#elif (defined(MODULE_CONTROLLER_MANAGER) || __has_include("MJNavigationController.h"))
#define HEADER_NAVIGATION_CONTROLLER    "MJNavigationController.h"
#define THENavigationController         MJNavigationController
#else
#define HEADER_NAVIGATION_CONTROLLER    <UIKit/UINavigationController.h>
#define THENavigationController         UINavigationController
#endif
// ControllerManager
#if __has_include("ControllerManager.h")
#define HEADER_CONTROLLER_MANAGER   "ControllerManager.h"
#define THEControllerManager        ControllerManager
#elif (defined(MODULE_CONTROLLER_MANAGER) || __has_include("MJControllerManager.h"))
#define HEADER_CONTROLLER_MANAGER   "MJControllerManager.h"
#define THEControllerManager        MJControllerManager
#endif
#if __has_include("MJWindowRootViewController.h")
#define HEADER_WINDOW_ROOT_VIEW_CONTROLLER  "MJWindowRootViewController.h"
#define THEWindowRootViewController         MJWindowRootViewController
#else
#define HEADER_WINDOW_ROOT_VIEW_CONTROLLER  HEADER_BASE_VIEW_CONTROLLER
#define THEWindowRootViewController         THEBaseViewController
#endif



#endif /* ModuleCapability_h */
