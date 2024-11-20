#import "RNPermissionHandlerNotifications.h"

#import <UserNotifications/UserNotifications.h>

@interface RNPermissionHandlerNotifications()

@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status, NSDictionary * _Nonnull settings);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerNotifications

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.NOTIFICATIONS";
}

- (RNPermissionStatus)convertStatus:(UNAuthorizationStatus)status {
  switch (status) {
    case UNAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case UNAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
#if !TARGET_OS_TV
    case UNAuthorizationStatusEphemeral:
      return RNPermissionStatusLimited;
#endif
    case UNAuthorizationStatusAuthorized:
    case UNAuthorizationStatusProvisional:
      return RNPermissionStatusAuthorized;
  }
}

- (NSDictionary * _Nonnull)convertSettings:(UNNotificationSettings * _Nonnull)settings {
  NSMutableDictionary *result = [NSMutableDictionary new];

  [result setValue:@(settings.authorizationStatus == UNAuthorizationStatusProvisional) forKey:@"provisional"];

  if (settings.badgeSetting != UNNotificationSettingNotSupported) {
    [result setValue:@(settings.badgeSetting == UNNotificationSettingEnabled) forKey:@"badge"];
  }

#if !TARGET_OS_TV
  [result setValue:@(settings.providesAppNotificationSettings == true) forKey:@"providesAppSettings"];

  if (settings.alertSetting != UNNotificationSettingNotSupported) {
    [result setValue:@(settings.alertSetting == UNNotificationSettingEnabled) forKey:@"alert"];
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
  if (settings.criticalAlertSetting != UNNotificationSettingNotSupported) {
    [result setValue:@(settings.criticalAlertSetting == UNNotificationSettingEnabled) forKey:@"criticalAlert"];
  }
#endif

  return result;
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve {
  [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    resolve([self convertStatus:settings.authorizationStatus], [self convertSettings:settings]);
  }];
}

- (void)requestWithOptions:(NSArray<NSString *> * _Nonnull)options
                  resolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                  rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject {
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

    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      resolve([self convertStatus:settings.authorizationStatus], [self convertSettings:settings]);
    }];
  }];
}

@end
