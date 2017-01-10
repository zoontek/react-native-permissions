//
//  RNPSpeechRecognition.m
//  ReactNativePermissions
//
//  Created by Tres Trantham on 01/10/17.
//  Copyright © 2017 Tres Trantham. All rights reserved.
//

#import "RNPSpeechRecognition.h"

#import <AVFoundation/AVFoundation.h>

@implementation RNPSpeechRecognition

+ (NSString *)getStatus:(NSString *)type
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

+ (void)request:(void (^)(NSString *))completionHandler
{
    void (^handler)(void) =  ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([self.class getStatus]);
        });
    };

    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        handler();
    }];
}

@end
