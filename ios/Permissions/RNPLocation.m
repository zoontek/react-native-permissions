//
//  RNPLocation.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#ifdef RNP_TYPE_LOCATION

#import "RNPLocation.h"
#import "RCTConvert+RNPStatus.h"


@interface RNPLocation() <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (copy) void (^completionHandler)(NSString *);
@end

@implementation RNPLocation

+ (RNPLocation *)sharedManager {
    static RNPLocation *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

+ (NSString *)getStatus:(id)json
{
    NSString *type = [RCTConvert NSString:json];
    
    return [self getStatusForType:type];
}

+ (NSString *)getStatusForType:(NSString *)type
{
    int status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return RNPStatusAuthorized;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return [type isEqualToString:@"always"] ? RNPStatusDenied : RNPStatusAuthorized;
        case kCLAuthorizationStatusDenied:
            return RNPStatusDenied;
        case kCLAuthorizationStatusRestricted:
            return RNPStatusRestricted;
        default:
            return RNPStatusUndetermined;
    }
}

+ (void)request:(void (^)(NSString *))completionHandler json:(id)json
{
    NSString *type = [RCTConvert NSString:json];
    NSString *status = [RNPLocation getStatusForType:nil];
    
    RNPLocation *sharedMgr = [self sharedManager];

    if (status == RNPStatusUndetermined) {
        sharedMgr.completionHandler = completionHandler;

        if (sharedMgr.locationManager == nil) {
            sharedMgr.locationManager = [[CLLocationManager alloc] init];
            sharedMgr.locationManager.delegate = sharedMgr;
        }

        if ([type isEqualToString:@"always"]) {
            [sharedMgr.locationManager requestAlwaysAuthorization];
        } else {
            [sharedMgr.locationManager requestWhenInUseAuthorization];
        }
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && [type isEqualToString:@"always"]) {
            completionHandler(RNPStatusDenied);
        } else {
            completionHandler(status);
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        if (self.locationManager) {
            self.locationManager.delegate = nil;
            self.locationManager = nil;
        }

        if (self.completionHandler) {
            //for some reason, checking permission right away returns denied. need to wait a tiny bit
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.completionHandler([self.class getStatusForType:nil]);
                self.completionHandler = nil;
            });
        }
    }
}

@end

#endif
