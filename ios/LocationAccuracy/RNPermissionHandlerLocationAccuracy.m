#import "RNPermissionHandlerLocationAccuracy.h"

@import CoreLocation;

@interface RNPermissionHandlerLocationAccuracy() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerLocationAccuracy

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationTemporaryUsageDescriptionDictionary"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_ACCURACY";
}

- (void)checkWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                 rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  if (@available(iOS 14, *)) {
    if (![CLLocationManager locationServicesEnabled]) {
      return reject(@"cannot_check_location_accuracy", @"Location services are disabled", nil);
    }

    switch ([CLLocationManager authorizationStatus]) {
      case kCLAuthorizationStatusNotDetermined:
        return reject(@"cannot_check_location_accuracy", @"Location permission hasn't been requested first", nil);
      case kCLAuthorizationStatusRestricted:
      case kCLAuthorizationStatusDenied:
        return reject(@"cannot_check_location_accuracy", @"Location permission has been blocked by the user", nil);
      case kCLAuthorizationStatusAuthorizedWhenInUse:
      case kCLAuthorizationStatusAuthorizedAlways:
        break;
    }

    CLLocationManager *locationManager = [CLLocationManager new];

    switch (locationManager.accuracyAuthorization) {
      case CLAccuracyAuthorizationFullAccuracy:
        return resolve(@"full");
      case CLAccuracyAuthorizationReducedAccuracy:
        return resolve(@"reduced");
    }
  } else {
    reject(@"cannot_check_location_accuracy", @"Only available on iOS 14 or higher", nil);
  }
}

- (void)requestWithPurposeKey:(NSString * _Nonnull)purposeKey
                     resolver:(RCTPromiseResolveBlock _Nonnull)resolve
                     rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  if (@available(iOS 14, *)) {
    if (![CLLocationManager locationServicesEnabled]) {
      return reject(@"cannot_request_location_accuracy", @"Location services are disabled", nil);
    }

    switch ([CLLocationManager authorizationStatus]) {
      case kCLAuthorizationStatusNotDetermined:
        return reject(@"cannot_request_location_accuracy", @"Location permission hasn't been requested first", nil);
      case kCLAuthorizationStatusRestricted:
      case kCLAuthorizationStatusDenied:
        return reject(@"cannot_request_location_accuracy", @"Location permission has been blocked by the user", nil);
      case kCLAuthorizationStatusAuthorizedWhenInUse:
      case kCLAuthorizationStatusAuthorizedAlways:
        break;
    }

    CLLocationManager *locationManager = [CLLocationManager new];

    switch (locationManager.accuracyAuthorization) {
      case CLAccuracyAuthorizationFullAccuracy:
        return resolve(@"full"); // resolve early if full accuracy is already granted
      case CLAccuracyAuthorizationReducedAccuracy:
        break;
    }

    [locationManager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey
                                                                  completion:^(NSError * _Nullable error) {
      if (error) {
        reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
      } else {
        switch (locationManager.accuracyAuthorization) {
          case CLAccuracyAuthorizationFullAccuracy:
            return resolve(@"full");
          case CLAccuracyAuthorizationReducedAccuracy:
            return resolve(@"reduced");
        }
      }
    }];
  } else {
    reject(@"cannot_request_location_accuracy", @"Only available on iOS 14 or higher", nil);
  }
}

@end
