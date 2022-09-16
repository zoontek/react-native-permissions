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
  
  if (authorizationStatus != kCLAuthorizationStatusNotDetermined
      && (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse
          && requestedBefore)) {
    return [self checkWithResolver:resolve rejecter:reject];
  }
  
  _resolve = resolve;
  _reject = reject;
  
  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];
  
  // When we request location always permission, if the user selects "Keep Only While Using", iOS
  // won't trigger the locationManager:didChangeAuthorizationStatus: delegate method. This means we
  // can't know when the user has responded to the permission prompt directly.
  //
  // We can get around this by listening for the UIApplicationDidBecomeActiveNotification event which posts
  // when the application regains focus from the permission prompt. When this happens we'll
  // trigger the applicationDidBecomeActive method on this class, and we'll check the authorization status and
  // resolve the promise there -- letting us stay consistent with our promise-based API.
  //
  // References:
  // ===========
  // CLLocationManager requestAlwaysAuthorization:
  // https://developer.apple.com/documentation/corelocation/cllocationmanager/1620551-requestalwaysauthorization?language=objc
  //
  // NSNotificationCenter addObserver:
  // https://developer.apple.com/documentation/foundation/nsnotificationcenter/1415360-addobserver
  //
  // UIApplicationDidBecomeActiveNotification:
  // https://developer.apple.com/documentation/uikit/uiapplicationdidbecomeactivenotification
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(applicationDidBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
  
  [_locationManager requestAlwaysAuthorization];
  [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];
}

- (void)resolveWithNewAuthorizationStatusAndCleanup {
  [self checkWithResolver:_resolve rejecter:_reject];
  [_locationManager setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];
}

- (void)applicationDidBecomeActive {
  [self resolveWithNewAuthorizationStatusAndCleanup];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  [self resolveWithNewAuthorizationStatusAndCleanup];
}

@end
