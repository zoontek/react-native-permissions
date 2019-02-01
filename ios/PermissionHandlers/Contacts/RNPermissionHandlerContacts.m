#import "RNPermissionHandlerContacts.h"

@import Contacts;

@implementation RNPermissionHandlerContacts

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSContactsUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
    case CNAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case CNAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case CNAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case CNAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil && error.code != 100) {
      reject(error);
    } else {
      [self checkWithResolver:resolve withRejecter:reject];
    }
  }];
}

@end
