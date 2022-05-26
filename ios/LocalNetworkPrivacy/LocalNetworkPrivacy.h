@interface LocalNetworkPrivacy : NSObject

- (void)checkAccessState:(void (^)(BOOL))completion;

@end
