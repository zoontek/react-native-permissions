//
//  RNPBluetooth.h
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#if !defined RNP_PERMISSIONS_SELECTIVE || defined RNP_TYPE_BLUETOOTH

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "RNPPermission.h"

@interface RNPBluetooth : NSObject <CBPeripheralManagerDelegate, RNPPermission>

@end

#endif
