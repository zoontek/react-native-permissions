//
//  RCTConvert+RNPermissionsStatus.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 23/03/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RCTConvert+RNPermissionsStatus.h"

@implementation RCTConvert (RNPermissionsStatus)


RCT_ENUM_CONVERTER(RNPermissionsStatus, (@{ @"StatusUndetermined" : @(RNPermissionsStatusUndetermined),
                                             @"StatusDenied" : @(RNPermissionsStatusDenied),
                                             @"StatusAuthorized" : @(RNPermissionsStatusAuthorized),
                                             @"StatusRestricted" : @(RNPermissionsStatusRestricted)}),
                   RNPermissionsStatusUndetermined, integerValue)


@end
