//
//  RNPSpeechRecognition.m
//  ReactNativePermissions
//
//  Created by Tres Trantham on 1/11/17.
//  Copyright © 2017 Yonah Forst. All rights reserved.
//

#ifdef RNP_TYPE_SPEECH_RECOGNITION

#import "RNPSpeechRecognition.h"
#import <Speech/Speech.h>

@implementation RNPSpeechRecognition

+ (NSString *)getStatus:(id)json
{
  int status = [SFSpeechRecognizer authorizationStatus];

  switch (status) {
      case SFSpeechRecognizerAuthorizationStatusAuthorized:
          return RNPStatusAuthorized;
      case SFSpeechRecognizerAuthorizationStatusDenied:
          return RNPStatusDenied;
      case SFSpeechRecognizerAuthorizationStatusRestricted:
          return RNPStatusRestricted;
      default:
          return RNPStatusUndetermined;
  }
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    void (^handler)(void) =  ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus:nil]);
        });
    };

    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        handler();
    }];
}

@end

#endif
