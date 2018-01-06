//
//  RNPBackgroundRefresh.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPBackgroundRefresh.h"

@implementation RNPBackgroundRefresh

+(NSString *)getStatus
{
    int status = [[UIApplication sharedApplication] backgroundRefreshStatus];
    switch (status) {
        case UIBackgroundRefreshStatusAvailable:
            return RNPStatusAuthorized;
        case UIBackgroundRefreshStatusDenied:
            return RNPStatusDenied;
        case UIBackgroundRefreshStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }

}
@end
