//
//  RNPEvent.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_EVENT

#import "RNPEvent.h"
#import "RNPEventStore.h"

@implementation RNPEvent

+ (NSString *)getStatus:(id)json
{
    return [RNPEventStore getStatus:EKEntityTypeEvent];
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    [RNPEventStore request:EKEntityTypeEvent completionHandler:completionHandler];
}

@end

#endif
