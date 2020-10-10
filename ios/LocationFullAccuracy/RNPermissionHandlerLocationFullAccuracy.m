#import "RNPermissionHandlerLocationFullAccuracy.h"

@import CoreLocation;
@import UIKit;

@implementation RNPermissionHandlerLocationFullAccuracy

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationTemporaryUsageDescriptionDictionary"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_FULL_ACCURACY";
}

- (RNPermissionStatus)statusWithLocationManager:(CLLocationManager *)locationManager API_AVAILABLE(ios(14.0)) {
  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case kCLAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    default:
      break;
  }

  switch ([locationManager accuracyAuthorization]) {
    case CLAccuracyAuthorizationFullAccuracy:
      return RNPermissionStatusAuthorized;
    case CLAccuracyAuthorizationReducedAccuracy:
    default:
      return RNPermissionStatusNotDetermined;
  }
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  if (@available(iOS 14.0, *)) {
    CLLocationManager *locationManager = [CLLocationManager new];
    resolve([self statusWithLocationManager:locationManager]);
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(NSDictionary *_Nullable)options {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  if (@available(iOS 14.0, *)) {
    switch ([CLLocationManager authorizationStatus]) {
      case kCLAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case kCLAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      default:
        break;
    }

    CLLocationManager *locationManager = [CLLocationManager new];
    NSString *purposeKey = [options objectForKey:@"purposeKey"];

    if (!purposeKey) {
      purposeKey = @"full-accuracy";
    }

    [locationManager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey
                                                                  completion:^(NSError * _Nullable error) {
      RNPermissionStatus status = [self statusWithLocationManager:locationManager];

      // Ignore errors due to full accuracy already being authorized
      if (error && (error.code != kCLErrorPromptDeclined || status != RNPermissionStatusAuthorized)) {
        reject(error);
      } else {
        [self checkWithResolver:resolve rejecter:reject];
      }
    }];
  } else {
    return resolve(RNPermissionStatusNotAvailable);
  }
}

@end
