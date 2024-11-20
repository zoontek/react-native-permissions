#import "RNPermissionHandlerLocationAlways.h"

#import <CoreLocation/CoreLocation.h>

@interface RNPermissionHandlerLocationAlways() <CLLocationManagerDelegate>

@property (nonatomic, assign) bool observingApplicationWillResignActive;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);

@end

@implementation RNPermissionHandlerLocationAlways

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocationAlwaysAndWhenInUseUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCATION_ALWAYS";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case kCLAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case kCLAuthorizationStatusAuthorizedAlways:
      return RNPermissionStatusAuthorized;
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

  if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) {
    return resolve([self currentStatus]);
  }

  _resolve = resolve;

  _locationManager = [CLLocationManager new];
  [_locationManager setDelegate:self];

  if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    _observingApplicationWillResignActive = true;
    [self performSelector:@selector(onApplicationWillResignActiveCheck) withObject:nil afterDelay:0.25];
  }

  [_locationManager requestAlwaysAuthorization];
#endif
}

- (void)onApplicationWillResignActive {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _observingApplicationWillResignActive = false;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onApplicationDidBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
}

- (void)onApplicationWillResignActiveCheck {
  if (_observingApplicationWillResignActive) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _observingApplicationWillResignActive = false;

    [self resolveStatus:[CLLocationManager authorizationStatus]];
  }
}

- (void)onApplicationDidBecomeActive {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self resolveStatus:[CLLocationManager authorizationStatus]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined && !_observingApplicationWillResignActive) {
    [self resolveStatus:status];
  }
}

- (void)resolveStatus:(CLAuthorizationStatus)status {
  if (_resolve != nil) {
    _resolve([self currentStatus]);
    _resolve = nil;
    [_locationManager setDelegate:nil];
  }
}

@end
