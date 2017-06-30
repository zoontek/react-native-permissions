#import "RNPMediaLibrary.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RNPMediaLibrary


+ (NSString *)getStatus
    {

        int status = [MPMediaLibrary authorizationStatus];

        switch (status) {
            case MPMediaLibraryAuthorizationStatusNotDetermined: {
                return RNPStatusUndetermined;
            }
            case MPMediaLibraryAuthorizationStatusRestricted: {
                return RNPStatusRestricted;
            }
            case MPMediaLibraryAuthorizationStatusDenied: {
                return RNPStatusDenied;
            }
            case MPMediaLibraryAuthorizationStatusAuthorized: {
                return RNPStatusAuthorized;
            }
            default: {
                return RNPStatusUndetermined;
            }
        }
    }

+ (void)request:(void (^)(NSString *))completionHandler
    {
        void (^handler)(void) =  ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler([self.class getStatus]);
            });
        };

        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status){
            handler();
        }];
    }

@end
