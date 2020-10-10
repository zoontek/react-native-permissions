#import "RNPermissionHandlerAppTrackingTransparency.h"

@import AppTrackingTransparency;
@import AdSupport;

@implementation RNPermissionHandlerAppTrackingTransparency

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSUserTrackingUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.APP_TRACKING_TRANSPARENCY";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, *)) {
    switch ([ATTrackingManager trackingAuthorizationStatus]) {
      case ATTrackingManagerAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case ATTrackingManagerAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case ATTrackingManagerAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case ATTrackingManagerAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    if ([idfaString isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
      resolve(RNPermissionStatusDenied);
    } else {
      resolve(RNPermissionStatusAuthorized);
    }
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, *)) {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(__unused ATTrackingManagerAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    [self checkWithResolver:resolve rejecter:reject];
  }
}

@end
