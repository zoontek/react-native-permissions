//
//  RNPCamera.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPAudioVideo.h"

#import <AVFoundation/AVFoundation.h>

@implementation RNPAudioVideo

+ (NSString *)getStatus:(NSString *)type
{
    int status = [AVCaptureDevice authorizationStatusForMediaType:[self typeFromString:type]];
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
    [AVCaptureDevice requestAccessForMediaType:[self typeFromString:type]
                             completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completionHandler([RNPAudioVideo getStatus:type]);
                                 });
                             }];
}

+ (NSString *)typeFromString:(NSString *)string {
    if ([string isEqualToString:@"audio"]) {
        return AVMediaTypeAudio;
    } else {
        return AVMediaTypeVideo;
    }
}

@end
