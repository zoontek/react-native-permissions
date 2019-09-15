#import "RNPermissionHandlerLocationAlways.h"

@import CoreLocation;
@import UIKit;

@interface RNPermissionHandlerLocationAlways() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) bool initialChangeEventFired;
@property (nonatomic) bool isWaitingDidBecomeActive;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationAlways

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[
    @"NSLocationAlwaysAndWhenInUseUsageDescription",
    @"NSLocationAlwaysUsageDescription",
    @"NSLocationWhenInUseUsageDescription",
  ];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_ALWAYS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled] || ![RNPermissions isBackgroundModeEnabled:@"location"]) {
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

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled] || ![RNPermissions isBackgroundModeEnabled:@"location"]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

  if (status == kCLAuthorizationStatusAuthorizedAlways) {
    return resolve(RNPermissionStatusAuthorized);
  }

  _resolve = resolve;
  _reject = reject;
  _initialChangeEventFired = false;
  _isWaitingDidBecomeActive = false;

  if (status == kCLAuthorizationStatusAuthorizedWhenInUse && ![RNPermissions isFlaggedAsRequested:[[self class] handlerUniqueId]]) {
    _isWaitingDidBecomeActive = true;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UIApplicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
  }

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];
}

- (void)onAuthorizationStatus {
  [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];
  [self checkWithResolver:_resolve rejecter:_reject];

  [_locationManager setDelegate:nil];
  _locationManager = nil;

  if (_isWaitingDidBecomeActive) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
  }
}

- (void)UIApplicationDidBecomeActiveNotification:(NSNotification *)notification {
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self onAuthorizationStatus];
  }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  // @see https://github.com/iosphere/ISHPermissionKit/blob/2.1.2/ISHPermissionKit/Requests/ISHPermissionRequestLocation.m#L127
  if (status != kCLAuthorizationStatusNotDetermined && _initialChangeEventFired) {
    [self onAuthorizationStatus];
  } else {
    _initialChangeEventFired = true;
  }
}

@end
