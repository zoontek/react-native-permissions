#import "RNPermissionHandlerLocationAlways.h"

@import CoreLocation;
@import UIKit;

@interface RNPermissionHandlerLocationAlways() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationAlways

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationAlwaysAndWhenInUseUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_ALWAYS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  dispatch_async(dispatch_get_main_queue(), ^{
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
  });
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  dispatch_async(dispatch_get_main_queue(), ^{
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
    [self->_locationManager requestAlwaysAuthorization];
  });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined) {
    [_locationManager setDelegate:nil];
    [self checkWithResolver:_resolve rejecter:_reject];
  }
}

@end
