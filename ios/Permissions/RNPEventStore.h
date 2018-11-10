//
//  RNPEventStore.h
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 09.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_EVENT || defined RNP_TYPE_REMINDER

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface RNPEventStore : NSObject

+ (NSString *)getStatus:(EKEntityType)type;
+ (void)request:(EKEntityType)type completionHandler:(void (^)(NSString *))completionHandler;

@end

#endif
