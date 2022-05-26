#import <UIKit/UIKit.h>
#import "LocalNetworkPrivacy.h"

@interface LocalNetworkPrivacy () <NSNetServiceDelegate>

@property (nonatomic) NSNetService *service;
@property (nonatomic) void (^completion)(BOOL);
@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL publishing;

@end

@implementation LocalNetworkPrivacy

- (instancetype)init {
    if (self = [super init]) {
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_lnp._tcp." name:@"LocalNetworkPrivacy" port:1100];
    }
    return self;
}

- (void)dealloc {
    [self.service stop];
}

- (void)checkAccessState:(void (^)(BOOL))completion {
    self.completion = completion;

    self.publishing = YES;
    self.service.delegate = self;
    [self.service publish];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self.timer invalidate];
        self.completion(NO);
    }];
}


#pragma mark - NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)sender {
    [self.timer invalidate];
    self.completion(YES);
}

@end
