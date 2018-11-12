//
//  RNPPhoto.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#ifdef RNP_TYPE_PHOTO

#import "RNPPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>

@import Photos;

@implementation RNPPhoto

+ (NSString *)getStatus:(id)json
{
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
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    void (^handler)(void) =  ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus:nil]);
        });
    };

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        handler();
    }];
}
@end

#endif
