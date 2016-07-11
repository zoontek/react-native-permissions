//
//  PermissionsAsker.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 07/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "PermissionsAsker.h"

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <EventKit/EventKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "PermissionsChecker.h"

static PermissionsAsker *__sharedInstance;

@interface PermissionsAsker() <CLLocationManagerDelegate, CBPeripheralManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (copy) void (^notificationCompletionBlock)(RNPermissionsStatus);

@end


@implementation PermissionsAsker

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[PermissionsAsker alloc] init];
    });
    return __sharedInstance;
}


- (void)location:(NSString *)type
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([type isEqualToString:@"always"]) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)notification:(UIUserNotificationType)types completionHandler:(void (^)(RNPermissionsStatus))completionHandler
{
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:@"DidAskForNotifications"];
    if (!didAskForPermission) {
        self.notificationCompletionBlock = completionHandler;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            // iOS8+
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)types];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:@"DidAskForNotifications"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        RNPermissionsStatus status = [PermissionsChecker notification];
        completionHandler(status);
    }

}

- (void)applicationDidBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    //for some reason, checking permission right away returns denied. need to wait a tiny bit
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        RNPermissionsStatus status = [PermissionsChecker notification];
        self.notificationCompletionBlock(status);
        self.notificationCompletionBlock = nil;
    });
}

- (void)bluetooth
{
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self.peripheralManager startAdvertising:@{}];
}

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (self.peripheralManager) {
        [self.peripheralManager stopAdvertising];
        self.peripheralManager = nil;
    }
}




@end
