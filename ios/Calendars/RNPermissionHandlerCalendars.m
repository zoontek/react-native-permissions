#import "RNPermissionHandlerCalendars.h"

@import EventKit;

@implementation RNPermissionHandlerCalendars

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[
    @"NSCalendarsFullAccessUsageDescription",
    @"NSCalendarsUsageDescription",
  ];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CALENDARS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

  if (@available(iOS 17.0, *)) {
    switch (status) {
      case EKAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case EKAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case EKAuthorizationStatusDenied:
      case EKAuthorizationStatusWriteOnly:
        return resolve(RNPermissionStatusDenied);
      case EKAuthorizationStatusFullAccess:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    switch (status) {
      case EKAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case EKAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case EKAuthorizationStatusDenied:
      case EKAuthorizationStatusWriteOnly:
        return resolve(RNPermissionStatusDenied);
      case EKAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  EKEventStore *store = [EKEventStore new];

  if (@available(iOS 17.0, *)) {
    [store requestFullAccessToEventsWithCompletion:^(__unused BOOL granted, NSError * _Nullable error) {
      if (error != nil) {
        reject(error);
      } else {
        [self checkWithResolver:resolve rejecter:reject];
      }
    }];
  } else {
    [store requestAccessToEntityType:EKEntityTypeEvent
                          completion:^(__unused BOOL granted, NSError * _Nullable error) {
      if (error != nil) {
        reject(error);
      } else {
        [self checkWithResolver:resolve rejecter:reject];
      }
    }];
  }
}

@end
