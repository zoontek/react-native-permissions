//
//  RNPMotion.m
//  ReactNativePermissions
//

#import "RNPMotion.h"
#import <CoreMotion/CoreMotion.h>

@implementation RNPMotion

+ (NSString *)getStatus
{
    if (![CMMotionActivityManager isActivityAvailable]) {
        return RNPStatusRestricted;
    }
    
    if (@available(iOS 11.0, *)) {
        CMAuthorizationStatus status = [CMMotionActivityManager authorizationStatus];
        
        switch (status) {
            case CMAuthorizationStatusAuthorized:
                return RNPStatusAuthorized;
            case CMAuthorizationStatusDenied:
                return RNPStatusDenied;
            case CMAuthorizationStatusNotDetermined:
                return RNPStatusUndetermined;
            case CMAuthorizationStatusRestricted:
                return RNPStatusRestricted;
            default:
                return RNPStatusUndetermined;
        }
    } else {
        return RNPStatusRestricted;
    }
}

+ (void)request:(void (^)(NSString *))completionHandler
{
    __block NSString *status = [RNPMotion getStatus];
    
    if ([status isEqual: RNPStatusUndetermined]) {
        __block CMMotionActivityManager *activityManager = [[CMMotionActivityManager alloc] init];
        __block NSOperationQueue *motionActivityQueue = [[NSOperationQueue alloc] init];
        [activityManager queryActivityStartingFromDate:[NSDate distantPast] toDate:[NSDate date] toQueue:motionActivityQueue withHandler:^(NSArray *activities, NSError *error) {
            if (error) {
                status = RNPStatusDenied;
            } else if (activities || !error) {
                status = RNPStatusAuthorized;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(status);
            });
            
            activityManager = nil;
            motionActivityQueue = nil;
        }];
    } else {
        completionHandler(status);
    }
}
@end
