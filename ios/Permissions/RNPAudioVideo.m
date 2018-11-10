//
//  RNPCamera.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_MICROPHONE || defined RNP_TYPE_CAMERA

#import "RNPAudioVideo.h"
#import "RCTConvert+RNPStatus.h"

@implementation RNPAudioVideo

+ (NSString *)getStatus:(NSString *)type
{
    int status = [AVCaptureDevice authorizationStatusForMediaType:type];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case AVAuthorizationStatusDenied:
            return RNPStatusDenied;
        case AVAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
}

+ (void)request:(NSString *)type completionHandler:(void (^)(NSString *))completionHandler
{
    [AVCaptureDevice requestAccessForMediaType:type
                             completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completionHandler([RNPAudioVideo getStatus:type]);
                                 });
                             }];
}

@end

#endif
