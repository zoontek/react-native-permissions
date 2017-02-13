//
//  RCTConvert+RNPStatus
//  ReactNativePermissions
//
//  Created by Yonah Forst on 23/03/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import <React/RCTConvert.h>

static NSString* RNPStatusUndetermined = @"undetermined";
static NSString* RNPStatusDenied = @"denied";
static NSString* RNPStatusAuthorized = @"authorized";
static NSString* RNPStatusRestricted = @"restricted";


typedef NS_ENUM(NSInteger, RNPType) {
    RNPTypeUnknown,
    RNPTypeLocation,
    RNPTypeCamera,
    RNPTypeMicrophone,
    RNPTypePhoto,
    RNPTypeContacts,
    RNPTypeEvent,
    RNPTypeReminder,
    RNPTypeBluetooth,
    RNPTypeNotification,
    RNPTypeBackgroundRefresh,
    RNPTypeSpeechRecognition
};

@interface RCTConvert (RNPStatus)

@end
