//
//  RNPEvent.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPEvent.h"
#import <EventKit/EventKit.h>

@implementation RNPEvent

+ (NSString *)getStatus:(NSString *)type
{
    int status = [EKEventStore authorizationStatusForEntityType:[self typeFromString:type]];

    switch (status) {
        case EKAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case EKAuthorizationStatusDenied:
            return RNPStatusDenied;
        case EKAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
}

+ (void)request:(NSString *)type completionHandler:(void (^)(NSString *))completionHandler
{
    EKEventStore *aStore = [[EKEventStore alloc] init];
    [aStore requestAccessToEntityType:[self typeFromString:type] completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self getStatus:type]);
        });
    }];
}

+(EKEntityType)typeFromString:(NSString *)string {
    if ([string isEqualToString:@"reminder"]) {
        return EKEntityTypeReminder;
    } else {
        return EKEntityTypeEvent;
    }
}

@end
