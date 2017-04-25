//
//  EANetworkManager.m
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/11.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//

#import "EANetworkManager.h"
#import "GCDAsyncSocket.h"

@interface EANetworkManager()<GCDAsyncSocketDelegate>

@property(nonatomic,retain)GCDAsyncSocket *asyncSocket;

@end

@implementation EANetworkManager

SINGLETON_T_FOR_CLASS(EANetworkManager);

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("EANetworkManagerQUeue",DISPATCH_QUEUE_CONCURRENT);
        _asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:queue];
    }
    return self;
}

- (void)connectToServer:(NSString *)host port:(int )port
{
    NSError *error = nil;
    [_asyncSocket connectToHost:host onPort:port error:&error];
}

#pragma mark --- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{//这里处理心跳
    NSLog(@"%s",__func__);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{

}

@end
