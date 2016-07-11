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
+ (RNPermissionsStatus)location;
+ (RNPermissionsStatus)camera;
+ (RNPermissionsStatus)microphone;
+ (RNPermissionsStatus)photo;
+ (RNPermissionsStatus)contacts;
+ (RNPermissionsStatus)event;
+ (RNPermissionsStatus)reminder;
+ (RNPermissionsStatus)bluetooth;
+ (RNPermissionsStatus)notification;
+ (RNPermissionsStatus)backgroundRefresh;

@end
