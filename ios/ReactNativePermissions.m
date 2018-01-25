//
//  ReactNativePermissions.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 18/02/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

@import Contacts;

#import "ReactNativePermissions.h"

#if __has_include(<React/RCTBridge.h>)
  #import <React/RCTBridge.h>
#elif __has_include("React/RCTBridge.h")
  #import "React/RCTBridge.h"
#else
  #import "RCTBridge.h"
#endif

#if __has_include(<React/RCTConvert.h>)
  #import <React/RCTConvert.h>
#elif __has_include("React/RCTConvert.h")
  #import "React/RCTConvert.h"
#else
  #import "RCTConvert.h"
#endif

#if __has_include(<React/RCTEventDispatcher.h>)
  #import <React/RCTEventDispatcher.h>
#elif __has_include("React/RCTEventDispatcher.h")
  #import "React/RCTEventDispatcher.h"
#else
  #import "RCTEventDispatcher.h"
#endif

#import "RNPLocation.h"
#import "RNPBluetooth.h"
#import "RNPNotification.h"
#import "RNPAudioVideo.h"
#import "RNPEvent.h"
#import "RNPPhoto.h"
#import "RNPContacts.h"
#import "RNPBackgroundRefresh.h"
#import "RNPSpeechRecognition.h"
#import "RNPMediaLibrary.h"
#import "RNPMotion.h"


@interface ReactNativePermissions()
@property (strong, nonatomic) RNPLocation *locationMgr;
@property (strong, nonatomic) RNPNotification *notificationMgr;
@property (strong, nonatomic) RNPBluetooth *bluetoothMgr;
@end

@implementation ReactNativePermissions


RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
    }

    return self;
}

/**
 * run on the main queue.
 */
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


RCT_REMAP_METHOD(canOpenSettings, canOpenSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@(UIApplicationOpenSettingsURLString != nil));
}


RCT_EXPORT_METHOD(openSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (@(UIApplicationOpenSettingsURLString != nil)) {

        NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
        id __block token = [center addObserverForName:UIApplicationDidBecomeActiveNotification
                                               object:nil
                                                queue:nil
                                           usingBlock:^(NSNotification *note) {
                                               [center removeObserver:token];
                                               resolve(@YES);
                                           }];

        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}


RCT_REMAP_METHOD(getPermissionStatus, getPermissionStatus:(RNPType)type json:(id)json resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;

    switch (type) {

        case RNPTypeLocation: {
            NSString *locationPermissionType = [RCTConvert NSString:json];
            status = [RNPLocation getStatusForType:locationPermissionType];
            break;
        }
        case RNPTypeCamera:
            status = [RNPAudioVideo getStatus:@"video"];
            break;
        case RNPTypeMicrophone:
            status = [RNPAudioVideo getStatus:@"audio"];
            break;
        case RNPTypePhoto:
            status = [RNPPhoto getStatus];
            break;
        case RNPTypeContacts:
            status = [RNPContacts getStatus];
            break;
        case RNPTypeEvent:
            status = [RNPEvent getStatus:@"event"];
            break;
        case RNPTypeReminder:
            status = [RNPEvent getStatus:@"reminder"];
            break;
        case RNPTypeBluetooth:
            status = [RNPBluetooth getStatus];
            break;
        case RNPTypeNotification:
            status = [RNPNotification getStatus];
            break;
        case RNPTypeBackgroundRefresh:
            status = [RNPBackgroundRefresh getStatus];
            break;
        case RNPTypeSpeechRecognition:
            status = [RNPSpeechRecognition getStatus];
            break;
        case RNPTypeMediaLibrary:
            status = [RNPMediaLibrary getStatus];
        case RNPTypeMotion:
            status = [RNPMotion getStatus];
            break;
        default:
            break;
    }

    resolve(status);
}

RCT_REMAP_METHOD(requestPermission, permissionType:(RNPType)type json:(id)json resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;

    switch (type) {
        case RNPTypeLocation:
            return [self requestLocation:json resolve:resolve];
        case RNPTypeCamera:
            return [RNPAudioVideo request:@"video" completionHandler:resolve];
        case RNPTypeMicrophone:
            return [RNPAudioVideo request:@"audio" completionHandler:resolve];
        case RNPTypePhoto:
            return [RNPPhoto request:resolve];
        case RNPTypeContacts:
            return [RNPContacts request:resolve];
        case RNPTypeEvent:
            return [RNPEvent request:@"event" completionHandler:resolve];
        case RNPTypeReminder:
            return [RNPEvent request:@"reminder" completionHandler:resolve];
        case RNPTypeBluetooth:
            return [self requestBluetooth:resolve];
        case RNPTypeNotification:
            return [self requestNotification:json resolve:resolve];
        case RNPTypeSpeechRecognition:
            return [RNPSpeechRecognition request:resolve];
        case RNPTypeMediaLibrary:
            return [RNPMediaLibrary request:resolve];
        case RNPTypeMotion:
            return [RNPMotion request:resolve];
        default:
            break;
    }


}

- (void) requestLocation:(id)json resolve:(RCTPromiseResolveBlock)resolve
{
    if (self.locationMgr == nil) {
        self.locationMgr = [[RNPLocation alloc] init];
    }

    NSString *type = [RCTConvert NSString:json];

    [self.locationMgr request:type completionHandler:resolve];
}

- (void) requestNotification:(id)json resolve:(RCTPromiseResolveBlock)resolve
{
    NSArray *typeStrings = [RCTConvert NSArray:json];

    UIUserNotificationType types;
    if ([typeStrings containsObject:@"alert"])
        types = types | UIUserNotificationTypeAlert;

    if ([typeStrings containsObject:@"badge"])
        types = types | UIUserNotificationTypeBadge;

    if ([typeStrings containsObject:@"sound"])
        types = types | UIUserNotificationTypeSound;


    if (self.notificationMgr == nil) {
        self.notificationMgr = [[RNPNotification alloc] init];
    }

    [self.notificationMgr request:types completionHandler:resolve];

}


- (void) requestBluetooth:(RCTPromiseResolveBlock)resolve
{
    if (self.bluetoothMgr == nil) {
        self.bluetoothMgr = [[RNPBluetooth alloc] init];
    }

    [self.bluetoothMgr request:resolve];
}




@end
