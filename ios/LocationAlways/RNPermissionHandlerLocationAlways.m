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
  return @[
    @"NSLocationAlwaysAndWhenInUseUsageDescription",
    @"NSLocationAlwaysUsageDescription",
  ];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_ALWAYS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case kCLAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case kCLAuthorizationStatusAuthorizedWhenInUse: {
      BOOL requestedBefore = [RNPermissions isFlaggedAsRequested:[[self class] handlerUniqueId]];
      if (requestedBefore) {
        return resolve(RNPermissionStatusDenied);
      }
      return resolve(RNPermissionStatusNotDetermined);
    }
    case kCLAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case kCLAuthorizationStatusAuthorizedAlways:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }
  
  CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
  BOOL requestedBefore = [RNPermissions isFlaggedAsRequested:[[self class] handlerUniqueId]];
  
  if (authorizationStatus != kCLAuthorizationStatusNotDetermined && (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse && requestedBefore)) {
    return [self checkWithResolver:resolve rejecter:reject];
  }

  _resolve = resolve;
  _reject = reject;

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestAlwaysAuthorization];
  [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) {
    [_locationManager setDelegate:nil];
    [self checkWithResolver:_resolve rejecter:_reject];
  }
}

@end
