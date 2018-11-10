//
//  RNPPhoto.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_MEDIA_LIBRARY

#import "RNPMediaLibrary.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RNPMediaLibrary

+ (NSString *)getStatus:(id)json
{
    int status = [MPMediaLibrary authorizationStatus];
    switch (status) {
        case MPMediaLibraryAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case MPMediaLibraryAuthorizationStatusDenied:
            return RNPStatusDenied;
        case MPMediaLibraryAuthorizationStatusRestricted:
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
    
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        handler();
    }];
}
@end

#endif
