#import "RNPermissionHandlerSpeechRecognition.h"

#if !TARGET_OS_TV
#import <Speech/Speech.h>
#endif

@implementation RNPermissionHandlerSpeechRecognition

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSSpeechRecognitionUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.SPEECH_RECOGNITION";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
  switch ([SFSpeechRecognizer authorizationStatus]) {
    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case SFSpeechRecognizerAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case SFSpeechRecognizerAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case SFSpeechRecognizerAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
  [SFSpeechRecognizer requestAuthorization:^(__unused SFSpeechRecognizerAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
#endif
}

@end
