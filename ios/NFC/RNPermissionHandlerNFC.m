#import "RNPermissionHandlerNFC.h"
#import <CoreNFC/CoreNFC.h>

bool isSupported() {
  bool result = false;  
  if (@available(iOS 11.0, *)) {
    @try {
      if (NFCNDEFReaderSession.readingAvailable) {
        result = true;
      }
    }
    @catch (NSException *exception) {
      NSLog(@"Exception thrown during NfcManager.isSupported: %@", exception);
    }
  }
  return result;
}

@implementation RNPermissionHandlerNFC

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NFCReaderUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.NFC";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (isSupported()) {
    return resolve(RNPermissionStatusAuthorized);
  } else {
    return resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
    [self checkWithResolver:resolve rejecter:reject];
}

@end