#import "RNPermissionHandlerMotion.h"

@import CoreMotion;

@interface RNPermissionHandlerMotion()

@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation RNPermissionHandlerMotion

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSMotionUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MOTION";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CMMotionActivityManager isActivityAvailable]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  switch ([CMMotionActivityManager authorizationStatus]) {
    case CMAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case CMAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case CMAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case CMAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (![CMMotionActivityManager isActivityAvailable]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  _activityManager = [CMMotionActivityManager new];
  _operationQueue = [NSOperationQueue new];
  _operationQueue.maxConcurrentOperationCount = 1;

  NSDate *now = [NSDate new];

  [_activityManager queryActivityStartingFromDate:now
                                           toDate:now
                                          toQueue:_operationQueue
                                      withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
    if (error != nil && error.code != CMErrorNotAuthorized && error.code != CMErrorMotionActivityNotAuthorized) {
      return reject(error);
    }

    if (error != nil) {
      return resolve(RNPermissionStatusDenied);
    }
    if (activities) {
      return resolve(RNPermissionStatusAuthorized);
    }

    return resolve(RNPermissionStatusNotDetermined);
  }];
}

@end
