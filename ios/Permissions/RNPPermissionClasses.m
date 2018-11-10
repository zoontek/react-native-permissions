//
//  RNPPermissionClasses.m
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 10.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#import "RNPPermissionClasses.h"

@implementation RNPPermissionClasses


+ (NSDictionary *)permissionClasses
{
    return @{
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_LOCATION
             @(RNPTypeLocation) : @"RNPLocation",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_CAMERA
             @(RNPTypeCamera) : @"RNPCamera",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_MICROPHONE
             @(RNPTypeMicrophone) : @"RNPMicrophone",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_PHOTO
             @(RNPTypePhoto) : @"RNPPhoto",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_CONTACTS
             @(RNPTypeContacts) : @"RNPContacts",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_EVENT
             @(RNPTypeEvent) : @"RNPEvent",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_REMINDER
             @(RNPTypeReminder) : @"RNPReminder",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_BLUETOOTH
             @(RNPTypeBluetooth) : @"RNPBluetooth",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_NOTIFICATION
             @(RNPTypeNotification) : @"RNPNotification",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_BACKGROUND_REFRESH
             @(RNPTypeBackgroundRefresh) : @"RNPBackgroundRefresh",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_SPEECH_RECOGNITION
             @(RNPTypeSpeechRecognition) : @"RNPSpeechRecognition",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_MEDIA_LIBRARY
             @(RNPTypeMediaLibrary) : @"RNPMediaLibrary",
#endif
#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_MOTION
             @(RNPTypeMotion) : @"RNPMotion",
#endif
             };
}

+ (Class<RNPPermission>)classForType:(RNPType)type
{
    NSString *className = [[self permissionClasses] objectForKey:@(type)];
    
    return NSClassFromString(className);
}

@end
