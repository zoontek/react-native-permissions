#import "RNPermissionHandlerLocationWhenInUse.h"

#import <CoreLocation/CoreLocation.h>

@interface RNPermissionHandlerLocationWhenInUse() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);

@end

@implementation RNPermissionHandlerLocationWhenInUse

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationWhenInUseUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_WHEN_IN_USE";
}

- (CLAuthorizationStatus)statusWithManager:(CLLocationManager *)manager {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    return [manager authorizationStatus];
  } else {
    return [CLLocationManager authorizationStatus];
  }
}

- (RNPermissionStatus)convertStatus:(CLAuthorizationStatus)status {
  switch (status) {
    case kCLAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case kCLAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case kCLAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways:
      return RNPermissionStatusAuthorized;
  }
}

- (RNPermissionStatus)currentStatus {
  return [self convertStatus:[self statusWithManager:[CLLocationManager new]]];
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  CLLocationManager *manager = [CLLocationManager new];
  CLAuthorizationStatus status = [self statusWithManager:manager];

  if (status != kCLAuthorizationStatusNotDetermined) {
    return resolve([self convertStatus:status]);
  }

  _locationManager = manager;
  _resolve = resolve;

  [_locationManager setDelegate:self];
  [_locationManager requestWhenInUseAuthorization];
}

#pragma mark - iOS 14+
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
  if ([manager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
    [self resolveStatus];
  }
}

#pragma mark - iOS < 14
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined) {
    [self resolveStatus];
  }
}

- (void)resolveStatus {
  if (_locationManager != nil && _resolve != nil) {
    CLAuthorizationStatus status = [self statusWithManager:_locationManager];

    [_locationManager setDelegate:nil];
    _locationManager = nil;

    _resolve([self convertStatus:status]);
    _resolve = nil;
  }
}

@end
