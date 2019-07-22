//
//  RNPNotification.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPNotification.h"
@import UserNotifications;

static NSString* RNPDidAskForNotification = @"RNPDidAskForNotification";

@interface RNPNotification()
@property (copy) void (^completionHandler)(NSString*);
@end

@implementation RNPNotification

+ (void)getStatusWithCompletionHandler:(void (^)(NSString*))completionHandler
{
    if (@available(iOS 10, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSString *status;
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    status = RNPStatusUndetermined;
                    break;
                    
                case UNAuthorizationStatusAuthorized:
                    status = RNPStatusAuthorized;
                    break;
                    
                default:
                    status = RNPStatusDenied;
                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(status);
            });            
        }];
    } else {
        BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:RNPDidAskForNotification];
        BOOL isEnabled = [[[UIApplication sharedApplication] currentUserNotificationSettings] types] != UIUserNotificationTypeNone;
        NSString *status;
        if (isEnabled) {
            status = RNPStatusAuthorized;
        } else {
            status = didAskForPermission ? RNPStatusDenied : RNPStatusUndetermined;
        }
        completionHandler(status);
    }
}


- (void)request:(UIUserNotificationType)types completionHandler:(void (^)(NSString*))completionHandler
{
    [self.class getStatusWithCompletionHandler:^(NSString *status) {
        if (status == RNPStatusUndetermined) {
            if (@available(iOS 10, *)) {
                UNAuthorizationOptions options = UNAuthorizationOptionNone;
                if (types & UIUserNotificationTypeAlert) {
                    options = options | UNAuthorizationOptionAlert;
                }
                if (types & UIUserNotificationTypeBadge) {
                    options = options | UNAuthorizationOptionBadge;
                }
                if (types & UIUserNotificationTypeSound) {
                    options = options | UNAuthorizationOptionSound;
                }
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center requestAuthorizationWithOptions:options
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler(granted ? RNPStatusAuthorized : RNPStatusDenied);
                                          });
                                      }];
            } else {
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
            }
        } else {
            completionHandler(status);
        }
    }];
}

- (void)applicationDidBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    if (self.completionHandler) {
        //for some reason, checking permission right away returns denied. need to wait a tiny bit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.class getStatusWithCompletionHandler:self.completionHandler];
            self.completionHandler = nil;
        });
    }
}

@end
