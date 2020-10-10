#import "RNPermissionHandlerReminders.h"

@import EventKit;

@implementation RNPermissionHandlerReminders

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSRemindersUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.REMINDERS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder]) {
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

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [[EKEventStore new] requestAccessToEntityType:EKEntityTypeReminder
                                     completion:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil) {
      reject(error);
    } else {
      [self checkWithResolver:resolve rejecter:reject];
    }
  }];
}

@end
