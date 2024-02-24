#import "RNPermissionHandlerSiri.h"

#import <Intents/Intents.h>

@implementation RNPermissionHandlerSiri

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSSiriUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.SIRI";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [INPreferences requestSiriAuthorization:^(__unused INSiriAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
