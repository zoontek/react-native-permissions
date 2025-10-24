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
  CLLocationManager *manager = [CLLocationManager new];

#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
  switch ([manager authorizationStatus]) {
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
  _resolve = resolve;

  if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
    [self performRequest];
  } else {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performRequest)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
  }
#endif
}

- (void)performRequest {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  CLLocationManager *manager = [CLLocationManager new];
  CLAuthorizationStatus status = [manager authorizationStatus];

  if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) {
    return _resolve([self currentStatus]);
  }

  _locationManager = manager;
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

    [self resolveStatus];
  }
}

- (void)onApplicationDidBecomeActive {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self resolveStatus];
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
  if ([manager authorizationStatus] != kCLAuthorizationStatusNotDetermined && !_observingApplicationWillResignActive) {
    [self resolveStatus];
  }
}

- (void)resolveStatus {
  if (_resolve != nil) {
    _resolve([self currentStatus]);
    _resolve = nil;
  }

  if (_locationManager != nil) {
    [_locationManager setDelegate:nil];
    _locationManager = nil;
  }
}

@end
