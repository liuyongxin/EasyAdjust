//
//  EANetworkManager.h
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/11.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NetworkManager  [EANetworkManager sharedInstance]
@interface EANetworkManager : NSObject

SINGLETON_T_FOR_HEADER(EANetworkManager);


- (void)connectToServer:(NSString *)host port:(int )port;


@end
