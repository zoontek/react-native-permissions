#import "RNPermissionHandlerStoreKit.h"

#import <StoreKit/StoreKit.h>

@implementation RNPermissionHandlerStoreKit

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.STOREKIT";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_SIMULATOR
  return RNPermissionStatusNotAvailable;
#else
  switch ([SKCloudServiceController authorizationStatus]) {
    case SKCloudServiceAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case SKCloudServiceAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case SKCloudServiceAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case SKCloudServiceAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [SKCloudServiceController requestAuthorization:^(__unused SKCloudServiceAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
}

@end
