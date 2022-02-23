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
      bool value = settings.alertSetting == UNNotificationSettingEnabled;
      [result setValue:@(value) forKey:@"alert"];
    }
    if (settings.badgeSetting != UNNotificationSettingNotSupported) {
      bool value = settings.badgeSetting == UNNotificationSettingEnabled;
      [result setValue:@(value) forKey:@"badge"];
    }
    if (settings.soundSetting != UNNotificationSettingNotSupported) {
      bool value = settings.soundSetting == UNNotificationSettingEnabled;
      [result setValue:@(value) forKey:@"sound"];
    }
    if (settings.lockScreenSetting != UNNotificationSettingNotSupported) {
      bool value = settings.lockScreenSetting == UNNotificationSettingEnabled;
      [result setValue:@(value) forKey:@"lockScreen"];
    }
    if (settings.carPlaySetting != UNNotificationSettingNotSupported) {
      bool value = settings.carPlaySetting == UNNotificationSettingEnabled;
      [result setValue:@(value) forKey:@"carPlay"];
    }
    if (settings.notificationCenterSetting != UNNotificationSettingNotSupported) {
      bool value = settings.notificationCenterSetting == UNNotificationSettingEnabled;
      [result setValue:@(value) forKey:@"notificationCenter"];
    }

    if (@available(iOS 12.0, *)) {
      bool provisionalValue = settings.authorizationStatus == UNAuthorizationStatusProvisional;
      [result setValue:@(provisionalValue) forKey:@"provisional"];

      if (settings.criticalAlertSetting != UNNotificationSettingNotSupported) {
        bool value = settings.criticalAlertSetting == UNNotificationSettingEnabled;
        [result setValue:@(value) forKey:@"criticalAlert"];
      }

      {
        bool value = settings.providesAppNotificationSettings == TRUE;
        [result setValue:@(value) forKey:@"providesAppNotificationSettings"];
      }
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
  bool providesAppNotificationSettings = [options containsObject:@"providesAppNotificationSettings"];

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

  if (@available(iOS 12.0, *)) {
    if (criticalAlert) {
      types += UNAuthorizationOptionCriticalAlert;
    }
    if (provisional) {
      types += UNAuthorizationOptionProvisional;
    }
    if (providesAppNotificationSettings) {
      types += UNAuthorizationOptionProvidesAppNotificationSettings;
    }
  }

  if (!alert &&
      !badge &&
      !sound &&
      !criticalAlert &&
      !carPlay &&
      !provisional &&
      !providesAppNotificationSettings) {
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
