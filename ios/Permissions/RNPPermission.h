//
//  RNPPermission.h
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 09.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#ifndef RNPPermission_h
#define RNPPermission_h

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"

@protocol RNPPermission

+ (NSString *)getStatus:(id)json;
+ (void)request:(void (^)(NSString *))completionHandler json:(id)json;

@end

#endif /* RNPPermission_h */
