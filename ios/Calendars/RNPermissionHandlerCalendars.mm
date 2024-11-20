#import "RNPermissionHandlerCalendars.h"

#if !TARGET_OS_TV
#import <EventKit/EventKit.h>
#endif

@implementation RNPermissionHandlerCalendars

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCalendarsFullAccessUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CALENDARS";
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
      return [RNPermissions isFlaggedAsRequested:[[self class] handlerUniqueId]] ? RNPermissionStatusDenied : RNPermissionStatusNotDetermined;
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
      [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];

      switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) {
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
    }
  };

  if (@available(iOS 17.0, *)) {
    [store requestFullAccessToEventsWithCompletion:completion];
  } else {
    [store requestAccessToEntityType:EKEntityTypeEvent completion:completion];
  }
#endif
}

@end
