#import "RNPermissionHandlerContacts.h"

#import <Contacts/Contacts.h>

@implementation RNPermissionHandlerContacts

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSContactsUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CONTACTS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
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

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts
                                 completionHandler:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil && error.code != 100) { // error code 100 is permission denied
      reject(error);
    } else {
      [self checkWithResolver:resolve rejecter:reject];
    }
  }];
}

@end
