//
//  PermissionsAsker.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 07/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCTConvert+RNPermissionsStatus.h"

@interface PermissionsAsker : NSObject

+ (instancetype)sharedInstance;
- (void)location:(NSString *)type;
- (void)notification:(UIUserNotificationType)types completionHandler:(void (^)(RNPermissionsStatus))completionHandler;
- (void)bluetooth;
- (void)camera;
- (void)microphone;
- (void)photo;
- (void)contacts;
- (void)event;
- (void)reminder;
- (void)backgroundRefresh;
@end
