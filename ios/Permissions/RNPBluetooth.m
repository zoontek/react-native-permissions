//
//  RNPBluetooth.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#ifdef RNP_TYPE_BLUETOOTH

#import "RNPBluetooth.h"
#import "RCTConvert+RNPStatus.h"

@interface RNPBluetooth() <CBPeripheralDelegate>
@property (strong, nonatomic) CBPeripheralManager* peripheralManager;
@property (copy) void (^completionHandler)(NSString *);
@end

@implementation RNPBluetooth

+ (RNPBluetooth *)sharedManager {
    static RNPBluetooth *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

+ (NSString *)getStatus:(id)json
{
    int status = [CBPeripheralManager authorizationStatus];
    switch (status) {
        case CBPeripheralManagerAuthorizationStatusAuthorized:
            return RNPStatusAuthorized;
        case CBPeripheralManagerAuthorizationStatusDenied:
            return RNPStatusDenied;
        case CBPeripheralManagerAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    NSString *status = [self.class getStatus:nil];
    
    RNPBluetooth *sharedMgr = [self sharedManager];
    
    if (status == RNPStatusUndetermined) {
        sharedMgr.completionHandler = completionHandler;
        
        sharedMgr.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:sharedMgr queue:nil];
        [sharedMgr.peripheralManager startAdvertising:@{}];
    } else {
        completionHandler(status);
    }
}

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (self.peripheralManager) {
        [self.peripheralManager stopAdvertising];
        self.peripheralManager.delegate = nil;
        self.peripheralManager = nil;
    }
    
    if (self.completionHandler) {
        //for some reason, checking permission right away returns denied. need to wait a tiny bit
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.completionHandler([self.class getStatus:nil]);
            self.completionHandler = nil;
        });
    }
    
}

@end

#endif
