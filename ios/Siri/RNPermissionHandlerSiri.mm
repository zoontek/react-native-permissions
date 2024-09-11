#import "RNPermissionHandlerSiri.h"

#import <Intents/Intents.h>

@implementation RNPermissionHandlerSiri

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSSiriUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.SIRI";
}

- (RNPermissionStatus)currentStatus {
  switch ([INPreferences siriAuthorizationStatus]) {
    case INSiriAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case INSiriAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case INSiriAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case INSiriAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [INPreferences requestSiriAuthorization:^(__unused INSiriAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
}

@end
