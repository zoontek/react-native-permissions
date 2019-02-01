#import "RNPermissionHandlerCalendars.h"

@import EventKit;

@implementation RNPermissionHandlerCalendars

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSCalendarsUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
    case EKAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case EKAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case EKAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case EKAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [self checkWithResolver:resolve withRejecter:reject];
    }
  }];
}

@end
