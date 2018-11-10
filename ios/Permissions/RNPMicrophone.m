//
//  RNPCameraAudio.m
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 09.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_MICROPHONE

#import "RNPMicrophone.h"
#import "RNPAudioVideo.h"

@implementation RNPMicrophone

+ (NSString *)getStatus:(id)json
{
    return [RNPAudioVideo getStatus:AVMediaTypeAudio];
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    [RNPAudioVideo request:AVMediaTypeAudio completionHandler:completionHandler];
}

@end

#endif
