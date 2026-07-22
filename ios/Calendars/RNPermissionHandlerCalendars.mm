#import "RNPermissionHandlerCalendars.h"

#if !TARGET_OS_TV
#import <EventKit/EventKit.h>

// Return a single, process-wide EKEventStore instance.
//
// Creating a new EKEventStore for every request exhausts the connections to the
// system "calaccessd" daemon on iOS 17+ ("Client tried to open too many connections
// to calaccessd. Refusing to open another."). Once that happens the static
// +[EKEventStore authorizationStatusForEntityType:] returns a stale value
// (typically EKAuthorizationStatusNotDetermined) for a while right after access is
// granted, even though the request completion handler reports granted == YES.
// Keeping one long-lived instance alive keeps the daemon connection healthy so the
// authorization status stays consistent between request() and a subsequent check().
// See https://developer.apple.com/forums/thread/737536
static EKEventStore *RNPermissionsSharedEventStore(void) {
  static EKEventStore *store = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    store = [EKEventStore new];
  });
  return store;
}
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
  void (^completion)(BOOL, NSError * _Nullable) = ^(BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];

      if (granted) {
        return resolve(RNPermissionStatusAuthorized);
      }

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

  EKEventStore *store = RNPermissionsSharedEventStore();

  if (@available(iOS 17.0, *)) {
    [store requestFullAccessToEventsWithCompletion:completion];
  } else {
    [store requestAccessToEntityType:EKEntityTypeEvent completion:completion];
  }
#endif
}

@end
