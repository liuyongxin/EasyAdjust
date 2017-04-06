//
//  EAProjectContext.h
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/6.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//

#import <Foundation/Foundation.h>

//屏幕 Frame 定义
#define ScreenWidth ([[UIScreen mainScreen]bounds].size.width)
#define ScreenHeight ([[UIScreen mainScreen]bounds].size.height)

#define ScreenStatusBarHeight MIN([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height)		// 动态获取系统状态栏高度

#define ScreenNavigationBarHeight 44
#define ScreenTabBarHeight      49


@interface EAProjectContext : NSObject

CM_DEFINE_SINGLETON_T_FOR_HEADER(EAProjectContext);


@end
