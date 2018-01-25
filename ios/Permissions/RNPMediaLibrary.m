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

+ (void)request:(void (^)(NSString *))completionHandler
{
    void (^handler)(void) =  ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus]);
        });
    };
    
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
        handler();
    }];
}
@end
