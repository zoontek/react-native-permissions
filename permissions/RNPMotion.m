//
//  RNPMotion.m
//  ReactNativePermissions
//

#import "RNPMotion.h"
#import <CoreMotion/CoreMotion.h>

@interface RNPMotion ()
@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) NSOperationQueue *motionActivityQueue;
@end

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
    __block NSString *status = [self getMotionPermissionStatus];
    
    if ([status isEqual: RNPStatusUndetermined]) {
        self.activityManager = [[CMMotionActivityManager alloc] init];
        self.motionActivityQueue = [[NSOperationQueue alloc] init];
        [self.activityManager queryActivityStartingFromDate:[NSDate distantPast] toDate:[NSDate date] toQueue:self.motionActivityQueue withHandler:^(NSArray *activities, NSError *error) {
            if (error) {
                status = RNPStatusDenied;
            } else if (activities || !error) {
                status = RNPStatusAuthorized;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(status);
            });
            
            [self setActivityManager:nil];
            [self setMotionActivityQueue:nil];
        }];
    } else {
        completionHandler(status);
    }
}
@end
