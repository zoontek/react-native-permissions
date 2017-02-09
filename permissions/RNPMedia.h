//
//  RNPMedia.h
//  ReactNativePermissions
//
//  Created by Senthil Sivanath on 9/18/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RCTConvert+RNPStatus.h"

@interface RNPMedia : NSObject

+ (NSString *)getStatus;
+ (void)request:(void (^)(NSString *))completionHandler;

@end
