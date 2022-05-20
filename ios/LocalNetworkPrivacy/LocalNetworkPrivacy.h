typedef enum {
  OptionalBoolNone,
  OptionalBoolYes,
  OptionalBoolNo,
} OptionalBool;

@interface LocalNetworkPrivacy : NSObject

+ (OptionalBool)authorizationStatus;
- (void)checkAccessState:(void (^)(BOOL))completion;

@end
