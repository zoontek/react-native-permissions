//
//  RNPAppleMusic.m
//  ReactNativePermissions
//
//  Created by Laurin Quast on 06/05/18.
//  Copyright © 2018 Laurin Quast. All rights reserved.
//

#import "RNPAppleMusic.h"

@implementation RNPAppleMusic

+ (NSString *)getStatus
{
    int status = [SKCloudServiceController authorizationStatus];
    switch (status) {
        case SKCloudServiceAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case SKCloudServiceAuthorizationStatusDenied:
            return RNPStatusDenied;
        case SKCloudServiceAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
}

+ (void)request:completionHandler:(void (^)(NSString *))completionHandler
{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([RNPAppleMusic getStatus]);
        });
    }];
}

@end
