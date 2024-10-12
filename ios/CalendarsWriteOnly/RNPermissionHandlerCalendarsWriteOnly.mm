#import "RNPermissionHandlerCalendarsWriteOnly.h"

#import <EventKit/EventKit.h>

@implementation RNPermissionHandlerCalendarsWriteOnly

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCalendarsWriteOnlyAccessUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CALENDARS_WRITE_ONLY";
}

- (RNPermissionStatus)currentStatus {
  switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
    case EKAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case EKAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case EKAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case EKAuthorizationStatusWriteOnly:
    case EKAuthorizationStatusFullAccess:
      return RNPermissionStatusAuthorized;
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  EKEventStore *store = [EKEventStore new];

  void (^completion)(BOOL, NSError * _Nullable) = ^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      resolve([self currentStatus]);
    }
  };

  if (@available(iOS 17.0, *)) {
    [store requestWriteOnlyAccessToEventsWithCompletion:completion];
  } else {
    [store requestAccessToEntityType:EKEntityTypeEvent completion:completion];
  }
}

@end
