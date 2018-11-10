//
//  RNPCameraVideo.m
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 09.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_CAMERA

#import "RNPCamera.h"
#import "RNPAudioVideo.h"

@implementation RNPCamera

+ (NSString *)getStatus:(id)json
{
    return [RNPAudioVideo getStatus:AVMediaTypeVideo];
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    [RNPAudioVideo request:AVMediaTypeVideo completionHandler:completionHandler];
}

@end

#endif
