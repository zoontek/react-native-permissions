//
//  RNPEventStore.m
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 09.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#if defined RNP_TYPE_EVENT || defined RNP_TYPE_REMINDER

#import "RNPEventStore.h"
#import "RCTConvert+RNPStatus.h"

@implementation RNPEventStore

+ (NSString *)getStatus:(EKEntityType)type
{
    int status = [EKEventStore authorizationStatusForEntityType:type];
    
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

+ (void)request:(EKEntityType)type completionHandler:(void (^)(NSString *))completionHandler
{
    EKEventStore *aStore = [[EKEventStore alloc] init];
    [aStore requestAccessToEntityType:type completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self getStatus:type]);
        });
    }];
}

@end

#endif
