//
//  ReactNativePermissions.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 18/02/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

@import Contacts;

#import "ReactNativePermissions.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

#import "RNPLocation.h"
#import "RNPBluetooth.h"
#import "RNPNotification.h"
#import "RNPAudioVideo.h"
#import "RNPEvent.h"
#import "RNPPhoto.h"
#import "RNPContacts.h"
#import "RNPBackgroundRefresh.h"

@interface ReactNativePermissions()
@property (strong, nonatomic) RNPLocation *locationMgr;
@property (strong, nonatomic) RNPNotification *notificationMgr;
@property (strong, nonatomic) RNPBluetooth *bluetoothMgr;
@end

@implementation ReactNativePermissions


RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (NSDictionary *)constantsToExport
{
    return @{ @"PermissionTypes" : @[ @"location",
                                      @"camera",
                                      @"microphone",
                                      @"photo",
                                      @"contacts",
                                      @"event",
                                      @"reminder",
                                      @"bluetooth",
                                      @"notification",
                                      @"backgroundRefresh" ]
              };
};


RCT_REMAP_METHOD(canOpenSettings, canOpenSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@(UIApplicationOpenSettingsURLString != nil));
}

RCT_EXPORT_METHOD(openSettings)
{
    if (@(UIApplicationOpenSettingsURLString != nil)) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

RCT_REMAP_METHOD(getPermissionStatus, getPermissionStatus:(RNPType)type resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;
    
    switch (type) {
            
        case RNPTypeLocation:
            status = [RNPLocation getStatus];
            break;
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
        default:
            break;
    }

    resolve(status);
}

RCT_REMAP_METHOD(requestLocation, requestLocation:(NSString *)type resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (self.locationMgr == nil) {
        self.locationMgr = [[RNPLocation alloc] init];
    }
    
    [self.locationMgr request:type completionHandler:resolve];
}

RCT_REMAP_METHOD(requestNotification, requestNotification:(NSArray *)typeStrings resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
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


RCT_REMAP_METHOD(requestBluetooth, requestBluetooth:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (self.bluetoothMgr == nil) {
        self.bluetoothMgr = [[RNPBluetooth alloc] init];
    }
    
    [self.bluetoothMgr request:resolve];
}

RCT_REMAP_METHOD(requestCamera, requestCamera:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [RNPAudioVideo request:@"video" completionHandler:resolve];
}

RCT_REMAP_METHOD(requestMicrophone, requestMicrophone:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [RNPAudioVideo request:@"audio" completionHandler:resolve];
}

RCT_REMAP_METHOD(requestEvent, requestEvents:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [RNPEvent request:@"event" completionHandler:resolve];
}

RCT_REMAP_METHOD(requestReminder, requestReminders:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [RNPEvent request:@"reminder" completionHandler:resolve];
}

RCT_REMAP_METHOD(requestPhoto, requestPhoto:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [RNPPhoto request:resolve];
}

RCT_REMAP_METHOD(requestContacts, requestContacts:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [RNPContacts request:resolve];
}






@end
