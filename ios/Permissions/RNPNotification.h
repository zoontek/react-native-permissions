//
//  RNPNotification.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#ifdef RNP_TYPE_NOTIFICATION

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"
#import "RNPPermission.h"

@interface RNPNotification : NSObject <RNPPermission>

@end

#endif
