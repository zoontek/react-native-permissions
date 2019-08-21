#import "RNPermissionHandlerNotifications.h"

@import UserNotifications;
@import UIKit;

@interface RNPermissionHandlerNotifications()

@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerNotifications

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.NOTIFICATIONS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      switch (settings.authorizationStatus) {
        case UNAuthorizationStatusNotDetermined:
#ifdef __IPHONE_12_0
        case UNAuthorizationStatusProvisional:
#endif
          return resolve(RNPermissionStatusNotDetermined);
        case UNAuthorizationStatusDenied:
          return resolve(RNPermissionStatusDenied);
        case UNAuthorizationStatusAuthorized:
          return resolve(RNPermissionStatusAuthorized);
      }
    }];
  } else {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];

    if ([settings types] != UIUserNotificationTypeNone) {
      return resolve(RNPermissionStatusAuthorized);
    } else if ([RNPermissions hasAlreadyBeenRequested:self]) {
      return resolve(RNPermissionStatusDenied);
    } else {
      return resolve(RNPermissionStatusNotDetermined);
    }
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  NSArray<NSString *> *options = [[NSArray alloc] initWithObjects:@"alert", @"badge", @"sound", nil];
  [self requestWithResolver:resolve rejecter:reject options:options];
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(NSArray<NSString *> * _Nonnull)options {
  bool alert = [options containsObject:@"alert"];
  bool badge = [options containsObject:@"badge"];
  bool sound = [options containsObject:@"sound"];
  bool criticalAlert = [options containsObject:@"criticalAlert"];
  bool carPlay = [options containsObject:@"carPlay"];
  bool provisional = [options containsObject:@"provisional"];

  if (@available(iOS 10.0, *)) {
    UNAuthorizationOptions types = UNAuthorizationOptionNone;

    if (alert) types += UNAuthorizationOptionAlert;
    if (badge) types += UNAuthorizationOptionBadge;
    if (sound) types += UNAuthorizationOptionSound;
    if (carPlay) types += UNAuthorizationOptionCarPlay;

    if (@available(iOS 12.0, *)) {
      if (criticalAlert) types += UNAuthorizationOptionCriticalAlert;
      if (provisional) types += UNAuthorizationOptionProvisional;
    }

    if (!alert && !badge && !sound && !criticalAlert && !carPlay && !provisional) {
      types += UNAuthorizationOptionAlert;
      types += UNAuthorizationOptionBadge;
      types += UNAuthorizationOptionSound;
    }

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center requestAuthorizationWithOptions:types
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
  } else {
    UIUserNotificationType types = UIUserNotificationTypeNone;

    if (alert) types += UIUserNotificationTypeAlert;
    if (badge) types += UIUserNotificationTypeBadge;
    if (sound) types += UIUserNotificationTypeSound;

    if (!alert && !badge && !sound) {
      types += UIUserNotificationTypeAlert;
      types += UIUserNotificationTypeBadge;
      types += UIUserNotificationTypeSound;
    }

    _resolve = resolve;
    _reject = reject;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onApplicationDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
}

- (void)onApplicationDidBecomeActive {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];

  [self checkWithResolver:_resolve rejecter:_reject];
}

- (void)getSettingsWithResolver:(void (^ _Nonnull)(NSDictionary * _Nonnull settings))resolve {
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      NSMutableDictionary *result = [NSMutableDictionary new];

      bool alert = settings.alertSetting == UNNotificationSettingEnabled;
      bool badge = settings.badgeSetting == UNNotificationSettingEnabled;
      bool sound = settings.soundSetting == UNNotificationSettingEnabled;
      bool lockScreen = settings.lockScreenSetting == UNNotificationSettingEnabled;
      bool carPlay = settings.carPlaySetting == UNNotificationSettingEnabled;

      if (settings.alertSetting != UNNotificationSettingNotSupported)
        [result setValue:@(alert) forKey:@"alert"];
      if (settings.badgeSetting != UNNotificationSettingNotSupported)
        [result setValue:@(badge) forKey:@"badge"];
      if (settings.soundSetting != UNNotificationSettingNotSupported)
        [result setValue:@(sound) forKey:@"sound"];
      if (settings.lockScreenSetting != UNNotificationSettingNotSupported)
        [result setValue:@(lockScreen) forKey:@"lockScreen"];
      if (settings.carPlaySetting != UNNotificationSettingNotSupported)
        [result setValue:@(carPlay) forKey:@"carPlay"];

      if (@available(iOS 12.0, *)) {
        bool criticalAlert = settings.criticalAlertSetting == UNNotificationSettingEnabled;

        if (settings.criticalAlertSetting != UNNotificationSettingNotSupported)
          [result setValue:@(criticalAlert) forKey:@"criticalAlert"];
      }

      resolve(result);
    }];
  } else {
    UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];

    resolve(@{
      @"alert": @((bool)(types & UIUserNotificationTypeAlert)),
      @"badge": @((bool)(types & UIUserNotificationTypeBadge)),
      @"sound": @((bool)(types & UIUserNotificationTypeSound)),
    });
  }
}

@end
