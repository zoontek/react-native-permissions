//
//  RNPPhoto.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPMediaLibrary.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RNPMediaLibrary

+ (NSString *)getStatus
{
#if TARGET_OS_SIMULATOR
    return RNPStatusRestricted;
#else
    if (@available(iOS 9.3, *)) {
        switch ([MPMediaLibrary authorizationStatus]) {
            case MPMediaLibraryAuthorizationStatusAuthorized:
                return RNPStatusAuthorized;
            case MPMediaLibraryAuthorizationStatusDenied:
                return RNPStatusDenied;
            case MPMediaLibraryAuthorizationStatusRestricted:
                return RNPStatusRestricted;
            default:
                return RNPStatusUndetermined;
        }
    } else {
        return RNPStatusAuthorized;
    }
#endif
}

+ (void)request:(void (^)(NSString *))completionHandler
{
#if TARGET_OS_SIMULATOR
    completionHandler(RNPStatusRestricted);
#else
    if (@available(iOS 9.3, *)) {
        void (^handler)(void) =  ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler([self.class getStatus]);
            });
        };

        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
            handler();
        }];
    } else {
        completionHandler(RNPStatusAuthorized);
    }
#endif
}

@end
