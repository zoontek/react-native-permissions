//
//  RNPMedia.m
//  ReactNativePermissions
//
//  Created by Senthil Sivanath on 9/18/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "RNPMedia.h"

@implementation RNPMedia

+ (NSString *)getStatus
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_3_0
    int status = [MPMediaLibrary authorizationStatus];
    switch (status) {
        case MPMediaLibraryAuthorizationStatusRestricted: {
            return RNPStatusRestricted;
        }
        case MPMediaLibraryAuthorizationStatusDenied: {
            return RNPStatusDenied;
        }
        case MPMediaLibraryAuthorizationStatusAuthorized: {
            return RNPStatusAuthorized;
        }
        default: {
            return RNPStatusUndetermined;
        }
    }
    #else
    return "authorized";
#endif
}
+ (void)request:(void (^)(NSString *))completionHandler
{
    void (^handler)(void) =  ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus]);
        });
    };
    
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        handler();
    }];
}

@end
