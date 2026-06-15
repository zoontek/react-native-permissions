#import "RNPermissionHandlerContacts.h"
#import <React/RCTUtils.h>

#if !TARGET_OS_TV
#import <Contacts/Contacts.h>

@protocol RNPermissionsContactsPickerInterface
- (void)presentFrom:(UIViewController * _Nonnull)viewController
         completion:(void (^ _Nonnull)(void))completion;
@end
#endif

@implementation RNPermissionHandlerContacts

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSContactsUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CONTACTS";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
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
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
  [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts
                                 completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (error != nil && error.code != 100) { // error code 100 is permission denied
      reject(error);
    } else if (granted) {
      // "granted" is YES for both full and limited access, so query the status to tell them apart
      resolve([self currentStatus] == RNPermissionStatusLimited ? RNPermissionStatusLimited : RNPermissionStatusAuthorized);
    } else {
      resolve([self currentStatus]);
    }
  }];
#endif
}

- (void)openContactsPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                              rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
#if TARGET_OS_TV
  reject(@"cannot_open_limited_picker", @"Only available on iOS 18 or higher", nil);
#else
  if (@available(iOS 18.0, *)) {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusLimited) {
      return reject(@"cannot_open_limited_picker", @"Contacts permission isn't limited", nil);
    }

    id picker = NSClassFromString(@"RNPermissionsContactsPicker");

    if (picker == nil) {
      return reject(@"cannot_open_limited_picker", @"Contact access picker is unavailable", nil);
    }

    UIViewController *viewController = RCTPresentedViewController();

    if (viewController == nil) {
      return reject(@"cannot_open_limited_picker", @"No presented view controller to present from", nil);
    }

    [(id<RNPermissionsContactsPickerInterface>)picker presentFrom:viewController
                                                       completion:^{
      resolve(@(true));
    }];
  } else {
    reject(@"cannot_open_limited_picker", @"Only available on iOS 18 or higher", nil);
  }
#endif
}

@end
