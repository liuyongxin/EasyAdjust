//
//  EAUtil.m
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/6.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//

#import "EAUtil.h"

@implementation EAUtil

+ (CGFloat)currentDeviceSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGFloat)currentShortAppVersion
{
    return 1;
}

@end
