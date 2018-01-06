//
//  RNPSpeechRecognition.h
//  ReactNativePermissions
//
//  Created by Tres Trantham on 1/11/17.
//  Copyright © 2017 Yonah Forst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"

@interface RNPSpeechRecognition : NSObject

+ (NSString *)getStatus;
+ (void)request:(void (^)(NSString *))completionHandler;

@end
