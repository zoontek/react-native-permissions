#import "RNPermissionHandlerLocationWhenInUse.h"

@import CoreLocation;

@interface RNPermissionHandlerLocationWhenInUse() <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) bool initialChangeEventFired;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationWhenInUse

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSLocationWhenInUseUsageDescription"];
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
    case kCLAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

  if (status != kCLAuthorizationStatusNotDetermined) {
    return [self checkWithResolver:resolve withRejecter:reject];
  }

  _resolve = resolve;
  _reject = reject;

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (!_initialChangeEventFired) {
    _initialChangeEventFired = true;
  } else {
    [self checkWithResolver:_resolve withRejecter:_reject];

    [_locationManager setDelegate:nil];
    _locationManager = nil;
  }
}

@end
