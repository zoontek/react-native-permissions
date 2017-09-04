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
#elif __has_include("RCTBridge.h")
  #import "RCTBridge.h"
#else
  #import "React/RCTBridge.h"
#endif


#if __has_include("RCTConvert.h")
  #import "RCTConvert.h"
#else
  #import <React/RCTConvert.h>
#endif

#if __has_include("RCTEventDispatcher.h")
  #import "RCTEventDispatcher.h"
#else
  #import <React/RCTEventDispatcher.h>
#endif

#import "RNPLocation.h"
#import "RNPNotification.h"
#import "RNPAudioVideo.h"
#import "RNPPhoto.h"
#import "RNPBackgroundRefresh.h"

@interface ReactNativePermissions()
@property (strong, nonatomic) RNPLocation *locationMgr;
@property (strong, nonatomic) RNPNotification *notificationMgr;
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
        case RNPTypePhoto:
            status = [RNPPhoto getStatus];
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

RCT_REMAP_METHOD(requestPermission, permissionType:(RNPType)type json:(id)json resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *status;
    
    switch (type) {
        case RNPTypeLocation:
            return [self requestLocation:json resolve:resolve];
        case RNPTypeCamera:
            return [RNPAudioVideo request:@"video" completionHandler:resolve];
        case RNPTypePhoto:
            return [RNPPhoto request:resolve];
        case RNPTypeNotification:
            return [self requestNotification:json resolve:resolve];
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

@end
