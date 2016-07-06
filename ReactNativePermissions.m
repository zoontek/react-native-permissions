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

#import "RCTConvert+RNPermissionsStatus.h"

#import "PermissionsChecker.h"

@interface ReactNativePermissions()
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
    return @{ @"StatusUndetermined" : @(RNPermissionsStatusUndetermined),
              @"StatusDenied" : @(RNPermissionsStatusDenied),
              @"StatusAuthorized" : @(RNPermissionsStatusAuthorized),
              @"StatusRestricted" : @(RNPermissionsStatusRestricted)};
};


RCT_REMAP_METHOD(canOpenSettings, canOpenSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([PermissionsChecker canOpenSettings]));
}
RCT_EXPORT_METHOD(openSettings) {
    [PermissionsChecker openSettings];
}
RCT_REMAP_METHOD(getPermissionStatus, getPermissionStatus:(NSString *)permission resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    SEL s = NSSelectorFromString([NSString stringWithFormat:@"%@PermissionStatus", permission]);
    RNPermissionsStatus status = (RNPermissionsStatus)[PermissionsChecker performSelector:s];
    resolve([self stringForStatus:status]);
}

- (NSString *)stringForStatus:(RNPermissionsStatus) status{
    switch (status) {
        case RNPermissionsStatusAuthorized:
            return @"authorized";
        case RNPermissionsStatusDenied:
            return @"denied";
        case RNPermissionsStatusRestricted:
            return @"restricted";
        case RNPermissionsStatusUndetermined:
        default:
            return @"undetermined";
    }
}

@end
