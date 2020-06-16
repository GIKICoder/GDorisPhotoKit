//
//  ConductorInner.h
//  GDorisPhotoKit
//
//  Created by GIKI on 2020/6/16.
//  Copyright © 2020 810373457@qq.com. All rights reserved.
//

#ifndef ConductorInner_h
#define ConductorInner_h

#if defined(DEBUG) && defined(CONDUCTOR_LOG)
#define ConductorLog(...) NSLog(@"CONDUCTOR_LOG: %@", [NSString stringWithFormat:__VA_ARGS__])
#else
    #define ConductorLog(...) do { } while (0)
    #ifndef NS_BLOCK_ASSERTIONS
        #define NS_BLOCK_ASSERTIONS
    #endif
#endif

#define CONDUCTOR_APP_QUEUE @"com.conductorapp.serialQueue"
#define CONDUCTOR_NONCON_APP_QUEUE @"com.conductorapp.concurrentQueue"

#endif /* ConductorInner_h */
