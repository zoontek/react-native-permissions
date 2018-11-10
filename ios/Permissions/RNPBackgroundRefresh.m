//
//  RNPBackgroundRefresh.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_BACKGROUND_REFRESH

#import "RNPBackgroundRefresh.h"

@implementation RNPBackgroundRefresh

+(NSString *)getStatus:(id)json
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

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    
}

@end

#endif
