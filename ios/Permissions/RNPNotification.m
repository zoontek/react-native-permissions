//
//  RNPNotification.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_NOTIFICATION

#import "RNPNotification.h"

static NSString* RNPDidAskForNotification = @"RNPDidAskForNotification";

@interface RNPNotification()
@property (copy) void (^completionHandler)(NSString*);
@end

@implementation RNPNotification

+ (RNPNotification *)sharedManager {
    static RNPNotification *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

+ (NSString *)getStatus:(id)json
{
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:RNPDidAskForNotification];
    BOOL isEnabled = [[[UIApplication sharedApplication] currentUserNotificationSettings] types] != UIUserNotificationTypeNone;

    if (isEnabled) {
        return RNPStatusAuthorized;
    } else {
        return didAskForPermission ? RNPStatusDenied : RNPStatusUndetermined;
    }
}


+ (UIUserNotificationType)typesFromJSON:(id)json
{
    NSArray *typeStrings = [RCTConvert NSArray:json];
    
    UIUserNotificationType types = UIUserNotificationTypeNone;

    if ([typeStrings containsObject:@"alert"])
        types = types | UIUserNotificationTypeAlert;
    
    if ([typeStrings containsObject:@"badge"])
        types = types | UIUserNotificationTypeBadge;
    
    if ([typeStrings containsObject:@"sound"])
        types = types | UIUserNotificationTypeSound;
    
    return types;
}


+ (void)request:(void (^)(NSString*))completionHandler json:(id)json
{
    NSString *status = [self getStatus:nil];
    UIUserNotificationType types = [self typesFromJSON:json];
    
    RNPNotification *sharedMgr = [self sharedManager];

    if (status == RNPStatusUndetermined) {
        sharedMgr.completionHandler = completionHandler;

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
            self.completionHandler([self.class getStatus:nil]);
            self.completionHandler = nil;
        });
    }
}

@end

#endif
