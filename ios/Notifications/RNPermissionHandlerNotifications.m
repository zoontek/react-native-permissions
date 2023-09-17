#import "RNPermissionHandlerNotifications.h"

@import UserNotifications;
@import UIKit;

@interface RNPermissionHandlerNotifications()

@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status, NSDictionary * _Nonnull settings);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerNotifications

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.NOTIFICATIONS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject {
  [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    NSMutableDictionary *result = [NSMutableDictionary new];

    if (settings.alertSetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.alertSetting == UNNotificationSettingEnabled) forKey:@"alert"];
    }
    if (settings.badgeSetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.badgeSetting == UNNotificationSettingEnabled) forKey:@"badge"];
    }
    if (settings.soundSetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.soundSetting == UNNotificationSettingEnabled) forKey:@"sound"];
    }
    if (settings.lockScreenSetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.lockScreenSetting == UNNotificationSettingEnabled) forKey:@"lockScreen"];
    }
    if (settings.carPlaySetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.carPlaySetting == UNNotificationSettingEnabled) forKey:@"carPlay"];
    }
    if (settings.notificationCenterSetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.notificationCenterSetting == UNNotificationSettingEnabled) forKey:@"notificationCenter"];
    }

    [result setValue:@(settings.providesAppNotificationSettings == true) forKey:@"providesAppSettings"];
    [result setValue:@(settings.authorizationStatus == UNAuthorizationStatusProvisional) forKey:@"provisional"];

    if (settings.criticalAlertSetting != UNNotificationSettingNotSupported) {
      [result setValue:@(settings.criticalAlertSetting == UNNotificationSettingEnabled) forKey:@"criticalAlert"];
    }

    switch (settings.authorizationStatus) {
      case UNAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined, result);
      case UNAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied, result);
      case UNAuthorizationStatusEphemeral:
        return resolve(RNPermissionStatusLimited, result);
      case UNAuthorizationStatusAuthorized:
      case UNAuthorizationStatusProvisional:
        return resolve(RNPermissionStatusAuthorized, result);
    }
  }];
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject
                    options:(NSArray<NSString *> * _Nonnull)options {
  bool alert = [options containsObject:@"alert"];
  bool badge = [options containsObject:@"badge"];
  bool sound = [options containsObject:@"sound"];
  bool criticalAlert = [options containsObject:@"criticalAlert"];
  bool carPlay = [options containsObject:@"carPlay"];
  bool provisional = [options containsObject:@"provisional"];
  bool providesAppSettings = [options containsObject:@"providesAppSettings"];

  UNAuthorizationOptions types = UNAuthorizationOptionNone;

  if (alert) {
    types += UNAuthorizationOptionAlert;
  }
  if (badge) {
    types += UNAuthorizationOptionBadge;
  }
  if (sound) {
    types += UNAuthorizationOptionSound;
  }
  if (carPlay) {
    types += UNAuthorizationOptionCarPlay;
  }
  if (criticalAlert) {
    types += UNAuthorizationOptionCriticalAlert;
  }
  if (provisional) {
    types += UNAuthorizationOptionProvisional;
  }
  if (providesAppSettings) {
    types += UNAuthorizationOptionProvidesAppNotificationSettings;
  }

  if (!alert &&
      !badge &&
      !sound &&
      !criticalAlert &&
      !carPlay &&
      !provisional &&
      !providesAppSettings) {
    types += UNAuthorizationOptionAlert;
    types += UNAuthorizationOptionBadge;
    types += UNAuthorizationOptionSound;
  }

  [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:types
                                                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      return reject(error);
    }

    if (granted) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] registerForRemoteNotifications];
      });
    }

    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
