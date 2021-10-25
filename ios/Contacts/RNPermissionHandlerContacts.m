#import "RNPermissionHandlerContacts.h"

#if !TARGET_OS_TV
@import Contacts;
#endif

@implementation RNPermissionHandlerContacts

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSContactsUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CONTACTS";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
    NSError * error = [[NSError alloc]
                       initWithDomain:@"RNPermissions"
                       code:1
                       userInfo:@{NSLocalizedDescriptionKey: @"Contacts not available on tvOS"}];
    return reject(error);
#elif
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
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
    NSError * error = [[NSError alloc]
                       initWithDomain:@"RNPermissions"
                       code:1
                       userInfo:@{NSLocalizedDescriptionKey: @"Contacts not available on tvOS"}];
    return reject(error);
#elif
  [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts
                                 completionHandler:^(__unused BOOL granted, NSError * _Nullable error) {
    if (error != nil && error.code != 100) { // error code 100 is permission denied
      reject(error);
    } else {
      [self checkWithResolver:resolve rejecter:reject];
    }
  }];
#endif
}

@end
