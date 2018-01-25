//
//  RCTConvert+RNPermissionsStatus.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 23/03/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RCTConvert+RNPStatus.h"

@implementation RCTConvert (RNPStatus)

RCT_ENUM_CONVERTER(RNPType, (@{ @"location" : @(RNPTypeLocation),
                                @"camera" : @(RNPTypeCamera),
                                @"microphone" : @(RNPTypeMicrophone),
                                @"photo" : @(RNPTypePhoto),
                                @"contacts" : @(RNPTypeContacts),
                                @"event" : @(RNPTypeEvent),
                                @"reminder" : @(RNPTypeReminder),
                                @"bluetooth" : @(RNPTypeBluetooth),
                                @"notification" : @(RNPTypeNotification),
                                @"backgroundRefresh": @(RNPTypeBackgroundRefresh),
                                @"speechRecognition": @(RNPTypeSpeechRecognition),
                                @"mediaLibrary": @(RNPTypeMediaLibrary),
                                @"motion": @(RNPTypeMotion)
                                }),
                                RNPTypeUnknown, integerValue)

@end
