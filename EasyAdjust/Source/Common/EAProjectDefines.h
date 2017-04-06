//
//  EAProjectDefines.h
//  EasyAdjust
//
//  Created by DZH_Louis on 2017/4/6.
//  Copyright © 2017年 DZH_Louis. All rights reserved.
//

#ifndef EAProjectDefines_h
#define EAProjectDefines_h

#if BUILD_ENV_CONF == BUILD_ENV_TEST
#import "EATestEnvironmentConfig.h"
#else
#import "EAOfficialEnvironmentConfig.h"
#endif

#import "EAProjectContext.h"
#import "EASingletonTemplate.h"


#endif /* EAProjectDefines_h */
