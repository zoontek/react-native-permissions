//
//  RNPPermissionClasses.h
//  ReactNativePermissions
//
//  Created by Artur Chrusciel on 10.11.18.
//  Copyright © 2018 Yonah Forst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"
#import "RNPPermission.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNPPermissionClasses : NSObject

+ (Class<RNPPermission>)classForType:(RNPType)type;

@end

NS_ASSUME_NONNULL_END
