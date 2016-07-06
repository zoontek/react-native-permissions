//
//  PermissionsChecker
//  PermissionsChecker
//
//  Created by Yonah Forst on 18/02/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//
#import "RCTConvert+RNPermissionsStatus.h"

@interface PermissionsChecker : NSObject

+ (BOOL)canOpenSettings;
+ (void)openSettings;
+ (RNPermissionsStatus)locationPermissionStatus;
+ (RNPermissionsStatus)cameraPermissionStatus;
+ (RNPermissionsStatus)microphonePermissionStatus;
+ (RNPermissionsStatus)photoPermissionStatus;
+ (RNPermissionsStatus)contactsPermissionStatus;
+ (RNPermissionsStatus)eventPermissionStatus;
+ (RNPermissionsStatus)reminderPermissionStatus;
+ (RNPermissionsStatus)bluetoothPermissionStatus;
+ (RNPermissionsStatus)notificationPermissionStatus;
+ (RNPermissionsStatus)backgroundRefreshPermissionStatus;

@end
