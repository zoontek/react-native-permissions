#import "RNPermissionHandlerNotifications.h"

@import UserNotifications;
@import UIKit;

@implementation RNPermissionHandlerNotifications

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  if (@available(iOS 10.0, *)) {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
      switch (settings.authorizationStatus) {
        case UNAuthorizationStatusNotDetermined:
          return resolve(RNPermissionStatusNotDetermined);
        case UNAuthorizationStatusDenied:
          return resolve(RNPermissionStatusDenied);
#ifdef __IPHONE_12_0
        case UNAuthorizationStatusProvisional:
#endif
        case UNAuthorizationStatusAuthorized:
          return resolve(RNPermissionStatusAuthorized);
      }
    }];
  } else {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];

    if (settings == nil || settings.types == UIUserNotificationTypeNone) {
      resolve(RNPermissionStatusNotDetermined);
    } else {
      resolve(RNPermissionStatusAuthorized);
    }
  }
}

- (void)requestWithOptions:(NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 10.0, *)) {
    UNAuthorizationOptions toRequest = UNAuthorizationOptionNone;

    if (options != nil) {
      NSArray<NSString *> *notificationOptions = [options objectForKey:@"notificationOptions"];

      if (notificationOptions != nil && [notificationOptions isKindOfClass:[NSArray class]]) {
#if RCT_DEV
        // @TODO check if it's possible to use RCTConvert + RCT_ENUM_CONVERTER
        // https://developer.apple.com/documentation/usernotifications/unnotificationsettings?language=objc

        NSArray<NSString *> *possible = [[NSArray alloc] initWithObjects:@"badge", @"sound", @"alert", @"carPlay", @"provisional", @"criticalAlert", nil];

        for (NSString *option in notificationOptions) {
          if (![possible containsObject:option]) {
            return [RNPermissionsManager logErrorMessage:[NSString stringWithFormat:@"Invalid notificationOptions value : %@. Must be one of : %@.", option, [possible componentsJoinedByString:@", "]]];
          }
        }
#endif

        if ([notificationOptions containsObject:@"badge"]) {
          toRequest += UNAuthorizationOptionBadge;
        }
        if ([notificationOptions containsObject:@"sound"]) {
          toRequest += UNAuthorizationOptionSound;
        }
        if ([notificationOptions containsObject:@"alert"]) {
          toRequest += UNAuthorizationOptionAlert;
        }
        if ([notificationOptions containsObject:@"carPlay"]) {
          toRequest += UNAuthorizationOptionCarPlay;
        }

        if (@available(iOS 12.0, *)) {
          if ([notificationOptions containsObject:@"provisional"]) {
            toRequest += UNAuthorizationOptionProvisional;
          }
          if ([notificationOptions containsObject:@"criticalAlert"]) {
            toRequest += UNAuthorizationOptionCriticalAlert;
          }
        }
      } else {
        toRequest += UNAuthorizationOptionBadge;
        toRequest += UNAuthorizationOptionSound;
        toRequest += UNAuthorizationOptionAlert;
      }
    }

    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:toRequest completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if (error != nil) {
        reject(error);
      } else {
        [self checkWithResolver:resolve withRejecter:reject];
      }
    }];
  } else {
    [self checkWithResolver:resolve withRejecter:reject];
  }
}

@end
