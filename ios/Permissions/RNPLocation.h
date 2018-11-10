//
//  RNPLocation.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_LOCATION

#import "RNPPermission.h"
#import <CoreLocation/CoreLocation.h>

@interface RNPLocation : NSObject <CLLocationManagerDelegate, RNPPermission>

@end

#endif
