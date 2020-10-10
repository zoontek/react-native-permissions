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

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CLLocationManager locationServicesEnabled]) {
    return resolve(RNPermissionStatusNotAvailable);
  }
  if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
    return [self checkWithResolver:resolve rejecter:reject];
  }

  _resolve = resolve;
  _reject = reject;

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  [_locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined) {
    [_locationManager setDelegate:nil];
    [self checkWithResolver:_resolve rejecter:_reject];
  }
}

- (void)askForFullLocationAccuracyWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                                      rejecter:(RCTPromiseRejectBlock _Nonnull)reject
                                    purposeKey:(NSString * _Nonnull)purposeKey {
  if (@available(iOS 14, *)) {
    NSString *key = @"NSLocationTemporaryUsageDescriptionDictionary";

    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:key]) {
      RCTLogError(@"Cannot ask for full accuracy without the required \"%@\" entry in your app \"Info.plist\" file", key);
      return;
    }

    if (![CLLocationManager locationServicesEnabled]) {
      return reject(@"cannot_ask_for_full_accuracy", @"Location services are disabled", nil);
    }

    switch ([CLLocationManager authorizationStatus]) {
      case kCLAuthorizationStatusNotDetermined:
        return reject(@"cannot_ask_for_full_accuracy", @"Location permission hasn't been requested first", nil);
      case kCLAuthorizationStatusRestricted:
      case kCLAuthorizationStatusDenied:
        return reject(@"cannot_ask_for_full_accuracy", @"Location permission has been blocked by the user", nil);
      case kCLAuthorizationStatusAuthorizedWhenInUse:
      case kCLAuthorizationStatusAuthorizedAlways:
        break;
    }

    CLLocationManager *locationManager = [CLLocationManager new];
    bool authorized = locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy;

    if (authorized) {
      return resolve(@(authorized));
    }

    [locationManager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:purposeKey
                                                                  completion:^(NSError * _Nullable error) {
      if (error) {
        reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
      } else {
        bool authorized = locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy;
        resolve(@(authorized));
      }
    }];
  } else {
    reject(@"cannot_ask_for_full_accuracy", @"Only available on iOS 14 or higher", nil);
  }
}

@end
