#import "RNPermissionHandlerSiri.h"

@import Intents;

@implementation RNPermissionHandlerSiri

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSSiriUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  if (@available(iOS 10.0, *)) {
    switch ([INPreferences siriAuthorizationStatus]) {
      case INSiriAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case INSiriAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case INSiriAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case INSiriAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 10.0, *)) {
    [INPreferences requestSiriAuthorization:^(__unused INSiriAuthorizationStatus status) {
      [self checkWithResolver:resolve withRejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
