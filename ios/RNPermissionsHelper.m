#import "RNPermissionsHelper.h"

@implementation RNPermissionsHelper

static NSString* SETTING_KEY = @"@RNPermissions:Requested";

+ (bool)isFlaggedAsRequested:(NSString * _Nonnull)handlerId {
  NSArray<NSString *> *requested = [[NSUserDefaults standardUserDefaults] arrayForKey:SETTING_KEY];
  return requested == nil ? false : [requested containsObject:handlerId];
}

+ (void)flagAsRequested:(NSString * _Nonnull)handlerId {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *requested = [[userDefaults arrayForKey:SETTING_KEY] mutableCopy];

  if (requested == nil) {
    requested = [NSMutableArray new];
  }

  if (![requested containsObject:handlerId]) {
    [requested addObject:handlerId];
    [userDefaults setObject:requested forKey:SETTING_KEY];
    [userDefaults synchronize];
  }
}

@end
