#import "RNPermissionHandlerStoreKit.h"

#import <StoreKit/StoreKit.h>

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
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [SKCloudServiceController requestAuthorization:^(__unused SKCloudServiceAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
