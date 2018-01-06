//
//  RNPContacts.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPContacts.h"
#import <AddressBook/AddressBook.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
@import Contacts;
#endif

@implementation RNPContacts

+ (NSString *)getStatus
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    int status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case CNAuthorizationStatusDenied:
            return RNPStatusDenied;
        case CNAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
#else
    int status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case kABAuthorizationStatusDenied:
            return RNPStatusDenied;
        case kABAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
#endif
}

+ (void)request:(void (^)(NSString *))completionHandler
{
    void (^handler)(BOOL, NSError * _Nullable) =  ^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus]);
        });
    };
    
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:handler];
#else
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        NSError *err = (__bridge NSError *)error;
        handler(granted, err);
    });
#endif
}

@end
