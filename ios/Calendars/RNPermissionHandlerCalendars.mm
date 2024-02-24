#import "RNPermissionHandlerCalendars.h"

#import <EventKit/EventKit.h>

@implementation RNPermissionHandlerCalendars

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCalendarsFullAccessUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CALENDARS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
    case EKAuthorizationStatusNotDetermined:
    case EKAuthorizationStatusWriteOnly:
      return resolve(RNPermissionStatusNotDetermined);
    case EKAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case EKAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case EKAuthorizationStatusFullAccess:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  EKEventStore *store = [EKEventStore new];

  void (^completion)(BOOL, NSError * _Nullable) = ^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [self checkWithResolver:resolve rejecter:reject];
    }
  };

  if (@available(iOS 17.0, *)) {
    [store requestFullAccessToEventsWithCompletion:completion];
  } else {
    [store requestAccessToEntityType:EKEntityTypeEvent completion:completion];
  }
}

@end
