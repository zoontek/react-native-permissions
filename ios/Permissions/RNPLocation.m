//
//  RNPLocation.m
//  ReactNativePermissions
//
//  Created by Yonah Forst on 11/07/16.
//  Copyright © 2016 Yonah Forst. All rights reserved.
//

#import "RNPLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface RNPLocation() <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSString * lastTypeRequested;
@property (strong, nonatomic) NSNumber * escelatedRightsRequested;
@property (copy) void (^completionHandler)(NSString *);
@end

@implementation RNPLocation
NSString *const EscalatedServiceRequested = @"RNP_ESCALATED_PERMISSION_REQUESTED";


+ (NSString *)getStatusForType:(NSString *)type
{
    int status = [CLLocationManager authorizationStatus];
    NSString * rnpStatus =  [RNPLocation convert:status for:type];
    return rnpStatus;
}


+(NSString*) convert:(CLAuthorizationStatus)status for:(NSString *) type{
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

-(id)init{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // Detect if user already has asked for escalated permission
        // kCLAuthorizationStatusAuthorizedWhenInUse -> kCLAuthorizationStatusAuthorizedAlways
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * hasEscalated = [defaults stringForKey:EscalatedServiceRequested];
        self.escelatedRightsRequested = [NSNumber numberWithBool: hasEscalated == nil ? NO : YES];

    }
    return self;
}

- (void)request:(NSString*)type completionHandler:(void (^)(NSString *))completionHandler
{
    int status = [CLLocationManager authorizationStatus];
    NSString * rnpStatus = [RNPLocation convert:status for:type];
    if (rnpStatus == RNPStatusUndetermined ||
        (status == kCLAuthorizationStatusAuthorizedWhenInUse && [type isEqualToString:@"always"] && ![self.escelatedRightsRequested boolValue])){
        self.lastTypeRequested = type;
        self.completionHandler = completionHandler;
        
        if ([type isEqualToString:@"always"]) {
            // Save the info about the 'always use' request we are about to make
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:EscalatedServiceRequested];
            [defaults synchronize];
            self.escelatedRightsRequested = [NSNumber numberWithBool:YES];
            
            [self.locationManager requestAlwaysAuthorization];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(self.completionHandler){
                    self.completionHandler(RNPStatusDenied);
                    self.completionHandler = nil;
                }
            });
            
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    } else {
        completionHandler(rnpStatus);
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSString * rnpStatus = [RNPLocation convert:status for:self.lastTypeRequested];
    if(rnpStatus != RNPStatusUndetermined){
        if (self.completionHandler) {
            NSString * rnpStatus = [RNPLocation convert:status for:self.lastTypeRequested];
            self.completionHandler(rnpStatus);
            self.completionHandler = nil;
        }
    }
}

@end

