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

- (RNPermissionStatus)currentStatus {
  switch ([CLLocationManager authorizationStatus]) {
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

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
    return resolve([self currentStatus]);
  }

  _resolve = resolve;

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined) {
    [_locationManager setDelegate:nil];
    _resolve([self currentStatus]);
  }
}

@end
