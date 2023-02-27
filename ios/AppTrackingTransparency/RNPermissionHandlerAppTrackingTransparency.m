#import "RNPermissionHandlerAppTrackingTransparency.h"

@import AppTrackingTransparency;
@import AdSupport;

@interface RNPermissionHandlerAppTrackingTransparency()

@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

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
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
      resolve(RNPermissionStatusAuthorized);
    } else {
      resolve(RNPermissionStatusDenied);
    }
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, *)) {
    if ([ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusNotDetermined) {
      return [self checkWithResolver:resolve rejecter:reject];
    }

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
      [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(__unused ATTrackingManagerAuthorizationStatus status) {
        [self checkWithResolver:resolve rejecter:reject];
      }];
    } else {
      _resolve = resolve;
      _reject = reject;

      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(onApplicationDidBecomeActive:)
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
    }
  } else {
    [self checkWithResolver:resolve rejecter:reject];
  }
}

- (void)onApplicationDidBecomeActive:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];

  if (@available(iOS 14.0, *)) {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(__unused ATTrackingManagerAuthorizationStatus status) {
      [self checkWithResolver:self->_resolve rejecter:self->_reject];
    }];
  }
}

@end
