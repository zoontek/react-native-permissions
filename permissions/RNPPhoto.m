//
//  RNPPhoto.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
@import Photos;
#endif

@implementation RNPPhoto

+ (NSString *)getStatus
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    int status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case PHAuthorizationStatusDenied:
            return RNPStatusDenied;
        case PHAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
#else
    int status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case kABAuthorizationStatusDenied:
            return RNPStatusDenied;
        case kABAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
#endif
}

+ (void)request:(void (^)(NSString *))completionHandler
{
    void (^handler)(void) =  ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus]);
        });
    };
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        handler();
    }];
#else
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        handler()
        *stop = YES;
    } failureBlock:^(NSError *error) {
        handler();
    }];
#endif
}
@end
