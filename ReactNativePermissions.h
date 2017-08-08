//
//  ReactNativePermissions.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 18/02/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if __has_include(<React/RCTBridge.h>)
  #import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
  #import "RCTBridge.h"
#else
  #import "React/RCTBridge.h"
#endif

@interface ReactNativePermissions : NSObject <RCTBridgeModule>


@end
