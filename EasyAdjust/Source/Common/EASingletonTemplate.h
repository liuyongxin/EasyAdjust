//
//  EASingletonTemplate.h
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/6.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//
#ifndef EASingletonTemplate_h
#define EASingletonTemplate_h

#define SINGLETON_T_FOR_HEADER(className) \
\
+ (className *)shared##className;\
+ (className *)sharedInstance;

#if !__has_feature(objc_arc)

#define SINGLETON_T_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [self init]; \
}); \
return shared##className; \
}\
\
+ (className *)sharedInstance { \
return [self shared##className];\
}\

#else

#define SINGLETON_T_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [self init]; \
}); \
return shared##className; \
}\
\
+ (className *)sharedInstance { \
return [self shared##className];\
}\

#endif

#endif /* EASingletonTemplate_h */
