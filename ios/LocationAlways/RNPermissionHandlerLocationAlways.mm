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

- (CLAuthorizationStatus)statusWithManager:(CLLocationManager *)manager {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    return [manager authorizationStatus];
  } else {
    return [CLLocationManager authorizationStatus];
  }
}

- (RNPermissionStatus)convertStatus:(CLAuthorizationStatus)status {
  switch (status) {
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
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
  return [self convertStatus:[self statusWithManager:[CLLocationManager new]]];
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
  CLAuthorizationStatus status = [self statusWithManager:manager];

  if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusAuthorizedWhenInUse) {
    return _resolve([self convertStatus:status]);
  }

  if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    _observingApplicationWillResignActive = true;
    [self performSelector:@selector(onApplicationWillResignActiveCheck) withObject:nil afterDelay:0.25];
  }

  _locationManager = manager;

  [_locationManager setDelegate:self];
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

#pragma mark - iOS 14+
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
  if ([manager authorizationStatus] != kCLAuthorizationStatusNotDetermined && !_observingApplicationWillResignActive) {
    [self resolveStatus];
  }
}

#pragma mark - iOS < 14
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusNotDetermined && !_observingApplicationWillResignActive) {
    [self resolveStatus];
  }
}

- (void)resolveStatus {
  if (_locationManager != nil && _resolve != nil) {
    CLAuthorizationStatus status = [self statusWithManager:_locationManager];

    [_locationManager setDelegate:nil];
    _locationManager = nil;

    _resolve([self convertStatus:status]);
    _resolve = nil;
  }
}

@end
