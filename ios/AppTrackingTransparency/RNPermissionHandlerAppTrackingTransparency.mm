#import "RNPermissionHandlerAppTrackingTransparency.h"

#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface RNPermissionHandlerAppTrackingTransparency()

@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);

@end

@implementation RNPermissionHandlerAppTrackingTransparency

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSUserTrackingUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.APP_TRACKING_TRANSPARENCY";
}

- (RNPermissionStatus)convertStatus:(ATTrackingManagerAuthorizationStatus)status API_AVAILABLE(ios(14)) {
  switch (status) {
    case ATTrackingManagerAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case ATTrackingManagerAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case ATTrackingManagerAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case ATTrackingManagerAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
}

- (RNPermissionStatus)currentStatus {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    return [self convertStatus:[ATTrackingManager trackingAuthorizationStatus]];
  } else {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
      return RNPermissionStatusAuthorized;
    } else {
      return RNPermissionStatusDenied;
    }
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    if ([ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusNotDetermined) {
      return resolve([self currentStatus]);
    }

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
      [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        resolve([self convertStatus:status]);
      }];
    } else {
      _resolve = resolve;

      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(onApplicationDidBecomeActive:)
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
    }
  } else {
    resolve([self currentStatus]);
  }
}

- (void)onApplicationDidBecomeActive:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];

  if (@available(iOS 14.0, tvOS 14.0, *)) {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
      self->_resolve([self convertStatus:status]);
    }];
  }
}

@end
