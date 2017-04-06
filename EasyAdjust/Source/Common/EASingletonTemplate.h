//
//  EASingletonTemplate.h
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/6.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//
#ifndef EASingletonTemplate_h
#define EASingletonTemplate_h

#define CM_DEFINE_SINGLETON_T_FOR_HEADER(className) +(className *)shared##className;

//\在代码中用于连接宏定义,以实现多行定义
#define CM_DEFINE_SINGLETON_T_FOR_CLASS(className) \
static className *_instance;\
+(id)shared##className{\
if(!_instance){\
_instance=[[self alloc]init];\
}\
return _instance;\
}\
+(id)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t dispatchOnce;\
dispatch_once(&dispatchOnce, ^{\
_instance=[super allocWithZone:zone];\
});\
return _instance;\
}

#endif /* EASingletonTemplate_h */
