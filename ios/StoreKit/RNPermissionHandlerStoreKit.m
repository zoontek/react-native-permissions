#import "RNPermissionHandlerStoreKit.h"

@import StoreKit;

@implementation RNPermissionHandlerStoreKit

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.STOREKIT";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else
  if (@available(iOS 9.3, *)) {
    switch ([SKCloudServiceController authorizationStatus]) {
      case SKCloudServiceAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case SKCloudServiceAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case SKCloudServiceAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case SKCloudServiceAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 9.3, *)) {
    [SKCloudServiceController requestAuthorization:^(__unused SKCloudServiceAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
