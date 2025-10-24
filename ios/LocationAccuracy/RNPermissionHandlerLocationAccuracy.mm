#import "RNPermissionHandlerLocationAccuracy.h"

#import <CoreLocation/CoreLocation.h>

@implementation RNPermissionHandlerLocationAccuracy

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationTemporaryUsageDescriptionDictionary"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_ACCURACY";
}

- (void)checkWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                 rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  CLLocationManager *manager = [CLLocationManager new];

  switch ([manager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return reject(@"cannot_check_location_accuracy", @"Location permission hasn't been requested first", nil);
    case kCLAuthorizationStatusRestricted:
    case kCLAuthorizationStatusDenied:
      return reject(@"cannot_check_location_accuracy", @"Location permission has been blocked by the user", nil);
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways:
      break;
  }

  switch (manager.accuracyAuthorization) {
    case CLAccuracyAuthorizationFullAccuracy:
      return resolve(@"full");
    case CLAccuracyAuthorizationReducedAccuracy:
      return resolve(@"reduced");
  }
}

- (void)requestWithPurposeKey:(NSString * _Nonnull)purposeKey
                     resolver:(RCTPromiseResolveBlock _Nonnull)resolve
                     rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  CLLocationManager *manager = [CLLocationManager new];

  switch ([manager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return reject(@"cannot_request_location_accuracy", @"Location permission hasn't been requested first", nil);
    case kCLAuthorizationStatusRestricted:
    case kCLAuthorizationStatusDenied:
      return reject(@"cannot_request_location_accuracy", @"Location permission has been blocked by the user", nil);
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways:
      break;
  }

  switch (manager.accuracyAuthorization) {
    case CLAccuracyAuthorizationFullAccuracy:
      return resolve(@"full"); // resolve early if full accuracy is already granted
    case CLAccuracyAuthorizationReducedAccuracy:
      break;
  }

  [manager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey
                                                                completion:^(NSError * _Nullable error) {
    if (error) {
      reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    } else {
      switch (manager.accuracyAuthorization) {
        case CLAccuracyAuthorizationFullAccuracy:
          return resolve(@"full");
        case CLAccuracyAuthorizationReducedAccuracy:
          return resolve(@"reduced");
      }
    }
  }];
}

@end
