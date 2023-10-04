#import "RNPermissionHandlerLocationWhenInUse.h"

@import CoreLocation;

@interface RNPermissionHandlerLocationWhenInUse() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationWhenInUse

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationWhenInUseUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_WHEN_IN_USE";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
  });
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (![CLLocationManager locationServicesEnabled]) {
      return resolve(RNPermissionStatusNotAvailable);
    }
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
      return [self checkWithResolver:resolve rejecter:reject];
    }

    self->_resolve = resolve;
    self->_reject = reject;

    self->_locationManager = [CLLocationManager new];
    [self->_locationManager setDelegate:self];
    [self->_locationManager requestWhenInUseAuthorization];
  });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined) {
    [_locationManager setDelegate:nil];
    [self checkWithResolver:_resolve rejecter:_reject];
  }
}

@end
