//
//  RNPNotification.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"

@interface RNPNotification : NSObject

+ (NSString *)getStatus;
- (void)request:(UIUserNotificationType)types completionHandler:(void (^)(NSString*))completionHandler;

@end
