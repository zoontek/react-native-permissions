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

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <EventKit/EventKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
@import Contacts;
@import Photos;
#endif


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


- (BOOL)canOpenSettings {
    return UIApplicationOpenSettingsURLString != nil;
}

RCT_REMAP_METHOD(canOpenSettings, canOpenSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@([self canOpenSettings]));
}

RCT_EXPORT_METHOD(openSettings)
{
    if ([self canOpenSettings]) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}


RCT_REMAP_METHOD(locationPermissionStatus, locationPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    int status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return resolve(@(RNPermissionsStatusAuthorized));
            
        case kCLAuthorizationStatusDenied:
            return resolve(@(RNPermissionsStatusDenied));
            
        case kCLAuthorizationStatusRestricted:
            return resolve(@(RNPermissionsStatusRestricted));
            
        default:
            return resolve(@(RNPermissionsStatusUndetermined));
    }
}


RCT_REMAP_METHOD(cameraPermissionStatus, cameraPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    int status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return resolve(@(RNPermissionsStatusAuthorized));
            
        case AVAuthorizationStatusDenied:
            return resolve(@(RNPermissionsStatusDenied));
            
        case AVAuthorizationStatusRestricted:
            return resolve(@(RNPermissionsStatusRestricted));
            
        default:
            return resolve(@(RNPermissionsStatusUndetermined));
    }

}

RCT_REMAP_METHOD(microphonePermissionStatus, microphonePermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    int status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return resolve(@(RNPermissionsStatusAuthorized));
            
        case AVAuthorizationStatusDenied:
            return resolve(@(RNPermissionsStatusDenied));
            
        case AVAuthorizationStatusRestricted:
            return resolve(@(RNPermissionsStatusRestricted));
            
        default:
            return resolve(@(RNPermissionsStatusUndetermined));
    }

}

RCT_REMAP_METHOD(photoPermissionStatus, photoPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

{
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
        int status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                return resolve(@(RNPermissionsStatusAuthorized));
                
            case PHAuthorizationStatusDenied:
                return resolve(@(RNPermissionsStatusDenied));
                
            case PHAuthorizationStatusRestricted:
                return resolve(@(RNPermissionsStatusRestricted));
                
            default:
                return resolve(@(RNPermissionsStatusUndetermined));
        }
    #else
        int status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusAuthorized:
                return resolve(@(RNPermissionsStatusAuthorized));
                
            case kABAuthorizationStatusDenied:
                return resolve(@(RNPermissionsStatusDenied));
                
            case kABAuthorizationStatusRestricted:
                return resolve(@(RNPermissionsStatusRestricted));
                
            default:
                return resolve(@(RNPermissionsStatusUndetermined));
        }
    #endif

}

RCT_REMAP_METHOD(contactsPermissionStatus, contactsPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
        int status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status) {
            case CNAuthorizationStatusAuthorized:
                return resolve(@(RNPermissionsStatusAuthorized));
                
            case CNAuthorizationStatusDenied:
                return resolve(@(RNPermissionsStatusDenied));
                
            case CNAuthorizationStatusRestricted:
                return resolve(@(RNPermissionsStatusRestricted));
                
            default:
                return resolve(@(RNPermissionsStatusUndetermined));
        }
    #else
        int status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusAuthorized:
                return resolve(@(RNPermissionsStatusAuthorized));
                
            case kABAuthorizationStatusDenied:
                return resolve(@(RNPermissionsStatusDenied));
                
            case kABAuthorizationStatusRestricted:
                return resolve(@(RNPermissionsStatusRestricted));
                
            default:
                return resolve(@(RNPermissionsStatusUndetermined));
        }
    #endif
}


RCT_REMAP_METHOD(eventPermissionStatus, eventPermission:(NSString *)eventString resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    int status;
    if ([eventString isEqualToString:@"reminder"]) {
        status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    } else if ([eventString isEqualToString:@"event"]) {
        status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    } else {
        NSError *error = [NSError errorWithDomain:@"invalidOption" code:-1 userInfo:NULL];
        return reject(@"-1", @"Type must be 'reminder' or 'event'", error);
    }
    
    switch (status) {
        case EKAuthorizationStatusAuthorized:
            return resolve(@(RNPermissionsStatusAuthorized));
            
        case EKAuthorizationStatusDenied:
            return resolve(@(RNPermissionsStatusDenied));
            
        case EKAuthorizationStatusRestricted:
            return resolve(@(RNPermissionsStatusRestricted));
            
        default:
            return resolve(@(RNPermissionsStatusUndetermined));
    }
}



RCT_REMAP_METHOD(bluetoothPermissionStatus, bluetoothPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    int status = [CBPeripheralManager authorizationStatus];
    
    switch (status) {
        case CBPeripheralManagerAuthorizationStatusAuthorized:
            return resolve(@(RNPermissionsStatusAuthorized));
            
        case CBPeripheralManagerAuthorizationStatusDenied:
            return resolve(@(RNPermissionsStatusDenied));
            
        case CBPeripheralManagerAuthorizationStatusRestricted:
            return resolve(@(RNPermissionsStatusRestricted));
            
        default:
            return resolve(@(RNPermissionsStatusUndetermined));
    }
    
}

//problem here is that we can only return Authorized or Undetermined
RCT_REMAP_METHOD(notificationPermissionStatus, notificationPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS8+
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            return resolve(@(RNPermissionsStatusAuthorized));
        }
        else {
            return resolve(@(RNPermissionsStatusUndetermined));
        }
    } else {
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
            if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
                return resolve(@(RNPermissionsStatusUndetermined));
            }
            else {
                return resolve(@(RNPermissionsStatusAuthorized));
            }
        #else
            return resolve(@(RNPermissionsStatusUndetermined));
        #endif

    }
}


@end
