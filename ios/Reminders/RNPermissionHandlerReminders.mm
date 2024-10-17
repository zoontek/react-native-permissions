#import "RNPermissionHandlerReminders.h"

#import <EventKit/EventKit.h>

@implementation RNPermissionHandlerReminders

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSRemindersFullAccessUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.REMINDERS";
}

- (RNPermissionStatus)currentStatus {
  switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
    case EKAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case EKAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case EKAuthorizationStatusDenied:
    case EKAuthorizationStatusWriteOnly:
      return RNPermissionStatusDenied;
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
    [store requestFullAccessToRemindersWithCompletion:completion];
  } else {
    [store requestAccessToEntityType:EKEntityTypeReminder completion:completion];
  }
}

@end
