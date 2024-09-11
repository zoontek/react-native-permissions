#import "RNPermissionHandlerContacts.h"

#import <Contacts/Contacts.h>

@implementation RNPermissionHandlerContacts

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSContactsUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CONTACTS";
}

- (RNPermissionStatus)currentStatus {
  switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
    case CNAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case CNAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case CNAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case CNAuthorizationStatusLimited:
      return RNPermissionStatusLimited;
    case CNAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts
                                 completionHandler:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil && error.code != 100) { // error code 100 is permission denied
      reject(error);
    } else {
      resolve([self currentStatus]);
    }
  }];
}

@end
