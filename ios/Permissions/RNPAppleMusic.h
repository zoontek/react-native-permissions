//
//  RNPAppleMusic.h
//  ReactNativePermissions
//
//  Created by Laurin Quast on 06/05/18.
//  Copyright © 2018 Laurin Quast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"
#import <StoreKit/StoreKit.h>

@interface RNPAppleMusic : NSObject

+ (NSString *)getStatus;
+ (void)request:(void (^)(NSString *))completionHandler;

@end
