#import "RNPermissionHandlerMotion.h"

@import CoreMotion;

static NSString* handlerKey = @"motion";

@interface RNPermissionHandlerMotion()

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) NSOperationQueue *motionActivityQueue;

@end

@implementation RNPermissionHandlerMotion

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSMotionUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (^)(NSError *error))reject {
  if (![CMMotionActivityManager isActivityAvailable]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  if (@available(iOS 11.0, *)) {
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

  if (![RNPermissionsManager hasBeenRequestedOnce:self]) {
    return resolve(RNPermissionStatusNotDetermined);
  }

  [self requestWithOptions:nil withResolver:resolve withRejecter:reject];
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (![CMMotionActivityManager isActivityAvailable]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  _motionActivityManager = [CMMotionActivityManager new];
  _motionActivityQueue = [NSOperationQueue new];

  [_motionActivityManager queryActivityStartingFromDate:[NSDate distantPast] toDate:[NSDate date] toQueue:_motionActivityQueue withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
    if (error != nil) {
      if (error.code == CMErrorNotAuthorized || error.code == CMErrorMotionActivityNotAuthorized) {
        resolve(RNPermissionStatusDenied);
      } else {
        reject(error);
      }
    } else if (activities) {
      resolve(RNPermissionStatusAuthorized);
    } else {
      resolve(RNPermissionStatusNotDetermined);
    }

    self->_motionActivityManager = nil;
    self->_motionActivityQueue = nil;
  }];
}

@end
