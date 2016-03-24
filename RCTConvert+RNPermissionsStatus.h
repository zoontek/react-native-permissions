//
//  RCTConvert+RNPermissionsStatus.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 23/03/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RCTConvert.h"

typedef NS_ENUM(NSInteger, RNPermissionsStatus) {
    RNPermissionsStatusUndetermined,
    RNPermissionsStatusDenied,
    RNPermissionsStatusAuthorized,
    RNPermissionsStatusRestricted
};

@interface RCTConvert (RNPermissionsStatus)

@end
