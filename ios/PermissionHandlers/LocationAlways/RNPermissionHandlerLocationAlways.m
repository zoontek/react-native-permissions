#import "RNPermissionHandlerLocationAlways.h"

@import CoreLocation;
@import UIKit;

@interface RNPermissionHandlerLocationAlways() <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) bool initialChangeEventFired;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationAlways

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[
    @"NSLocationAlwaysAndWhenInUseUsageDescription",
    @"NSLocationAlwaysUsageDescription",
  ];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case kCLAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case kCLAuthorizationStatusAuthorizedAlways:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

  if ((status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) ||
      ([RNPermissionsManager hasBeenRequestedOnce:self] && status == kCLAuthorizationStatusAuthorizedWhenInUse)) {
    return [self checkWithResolver:resolve withRejecter:reject];
  }

  _resolve = resolve;
  _reject = reject;

  if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
  }

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];
}

- (void)onAuthorizationStatus {
  [self checkWithResolver:_resolve withRejecter:_reject];

  [_locationManager setDelegate:nil];
  _locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (!_initialChangeEventFired) {
    _initialChangeEventFired = true;
  } else {
    [self onAuthorizationStatus];
  }
}

- (void)UIApplicationDidBecomeActiveNotification:(NSNotification *)notification {
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self onAuthorizationStatus];
  }

  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
