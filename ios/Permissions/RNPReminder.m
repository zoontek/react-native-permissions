//
//  RNPReminder.m
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 09.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#ifdef RNP_TYPE_REMINDER

#import "RNPReminder.h"
#import "RNPEventStore.h"

@implementation RNPReminder

+ (NSString *)getStatus:(id)json
{
    return [RNPEventStore getStatus:EKEntityTypeReminder];
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    [RNPEventStore request:EKEntityTypeReminder completionHandler:completionHandler];
}

@end

#endif
