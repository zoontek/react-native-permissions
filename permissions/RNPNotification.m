//
//  RNPNotification.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPNotification.h"

static NSString* RNPDidAskForNotification = @"RNPDidAskForNotification";

@interface RNPNotification()
@property (copy) void (^completionHandler)(NSString*);
@end

@implementation RNPNotification

+ (NSString *)getStatus
{
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:RNPDidAskForNotification];
    BOOL isEnabled = [[[UIApplication sharedApplication] currentUserNotificationSettings] types] != UIUserNotificationTypeNone;

    if (isEnabled) {
        return RNPStatusAuthorized;
    } else {
        return didAskForPermission ? RNPStatusDenied : RNPStatusUndetermined;
    }
}


- (void)request:(UIUserNotificationType)types completionHandler:(void (^)(NSString*))completionHandler
{
    NSString *status = [self.class getStatus];

    if (status == RNPStatusUndetermined) {
        self.completionHandler = completionHandler;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RNPDidAskForNotification];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        completionHandler(status);
    }
}

- (void)applicationDidBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    if (self.completionHandler) {
        //for some reason, checking permission right away returns denied. need to wait a tiny bit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.completionHandler([self.class getStatus]);
            self.completionHandler = nil;
        });
    }
}

@end
