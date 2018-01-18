//
//  RNPMotion.h
//  ReactNativePermissions
//

#import <Foundation/Foundation.h>
#import "RCTConvert+RNPStatus.h"

@interface RNPMotion : NSObject

+ (NSString *)getStatus;
+ (void)request:(void (^)(NSString *))completionHandler;

@end
