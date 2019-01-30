#import "RNPermissionHandlerStoreKit.h"

@import StoreKit;

@implementation RNPermissionHandlerStoreKit

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
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
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 9.3, *)) {
    [SKCloudServiceController requestAuthorization:^(__unused SKCloudServiceAuthorizationStatus status) {
      [self checkWithResolver:resolve withRejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
