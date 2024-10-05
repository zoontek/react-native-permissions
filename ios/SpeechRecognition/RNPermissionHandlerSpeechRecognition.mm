#import "RNPermissionHandlerSpeechRecognition.h"

#import <Speech/Speech.h>

@implementation RNPermissionHandlerSpeechRecognition

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSSpeechRecognitionUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.SPEECH_RECOGNITION";
}

- (RNPermissionStatus)currentStatus {
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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [SFSpeechRecognizer requestAuthorization:^(__unused SFSpeechRecognizerAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
}

@end
