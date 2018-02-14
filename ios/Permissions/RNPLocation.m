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
        
        // Have we asked for escelated
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * hasEscalated = [defaults stringForKey:@"escalated"];
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
            // Only allowed to ask once. Store so we know
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:@"escalated"];
            [defaults synchronize];
            self.escelatedRightsRequested = [NSNumber numberWithBool:YES];
            
            [self.locationManager requestAlwaysAuthorization];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    } else {
        completionHandler(rnpStatus);
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSString * rnpStatus = [RNPLocation convert:status for:nil];
    if(rnpStatus != RNPStatusUndetermined &&
       !(status == kCLAuthorizationStatusAuthorizedWhenInUse &&  [self.lastTypeRequested isEqualToString:@"always"]  && ![self.escelatedRightsRequested boolValue])){
        if (self.completionHandler) {
            NSString * rnpStatus = [RNPLocation convert:status for:self.lastTypeRequested];
            self.completionHandler(rnpStatus);
            self.completionHandler = nil;
        }
    }
    
}

@end

