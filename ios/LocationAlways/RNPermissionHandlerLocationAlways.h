#import "RNPermissions.h"

@interface RNPermissionHandlerLocationAlways : NSObject<RNPermissionHandler>

- (void)askForFullLocationAccuracyWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                                      rejecter:(RCTPromiseRejectBlock _Nonnull)reject
                                    purposeKey:(NSString * _Nonnull)purposeKey;

@end
