#import "RNPermissionHandlerCalendarsWriteOnly.h"

#if !TARGET_OS_TV
#import <EventKit/EventKit.h>
#endif

@implementation RNPermissionHandlerCalendarsWriteOnly

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCalendarsWriteOnlyAccessUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CALENDARS_WRITE_ONLY";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
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
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
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
#endif
}

@end
