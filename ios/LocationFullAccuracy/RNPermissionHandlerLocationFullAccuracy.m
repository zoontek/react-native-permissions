#import "RNPermissionHandlerLocationFullAccuracy.h"

@import CoreLocation;
@import UIKit;

NSErrorDomain const RNPermissionHandlerLocationFullAccuracyDomain = @"RNPermissionHandlerLocationFullAccuracy";
NS_ENUM(NSInteger) {
  RNPermissionHandlerLocationFullAccuracyNoPurposeKey = 1,
};

@interface RNPermissionHandlerLocationFullAccuracy()

@end

@implementation RNPermissionHandlerLocationFullAccuracy

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[
    @"NSLocationTemporaryUsageDescriptionDictionary"
  ];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_FULL_ACCURACY";
}

+ (RNPermissionStatus)getAccuracyStatus:(CLLocationManager *)locationManager API_AVAILABLE(ios(14.0)) {
  switch (locationManager.accuracyAuthorization) {
    case CLAccuracyAuthorizationFullAccuracy:
      return RNPermissionStatusAuthorized;
    case CLAccuracyAuthorizationReducedAccuracy:
    default:
      return RNPermissionStatusNotDetermined;
  }
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (!CLLocationManager.locationServicesEnabled) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  if (@available(iOS 14.0, *)) {
    CLLocationManager *locationManager = [CLLocationManager new];
    return resolve([RNPermissionHandlerLocationFullAccuracy getAccuracyStatus:locationManager]);
  } else {
    return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject
                    options:(NSDictionary *_Nullable)options {
  if (!CLLocationManager.locationServicesEnabled) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  if (@available(iOS 14.0, *)) {
    CLLocationManager *locationManager = [CLLocationManager new];
    NSString *purposeKey = [options objectForKey:@"temporaryPurposeKey"];

    if (!purposeKey) {
      purposeKey = @"full-accuracy";
    }

    [locationManager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey
                                                                  completion:^(NSError * _Nullable error) {
      RNPermissionStatus status = [RNPermissionHandlerLocationFullAccuracy getAccuracyStatus:locationManager];

      // Ignore errors due to full accuracy already being authorized
      if (error && (error.code != kCLErrorPromptDeclined || status != RNPermissionStatusAuthorized)) {
        return reject(error);
      } else {
        return resolve(status);
      }
    }];
  } else {
    return resolve(RNPermissionStatusAuthorized);
  }
}

@end
