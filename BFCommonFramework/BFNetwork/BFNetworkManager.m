//
//  BFNetworkManager.m
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import "BFNetworkManager.h"
#import "BFNetworkSocket.h"

NSString *const BFNetworkManagerQueueName = @"BFNetworkManagerQueue";
// server(Test)
NSString *const testHost =@"120.25.120.222";
NSUInteger testPort = 8866;

@interface BFNetworkManager () {
    // Queue
    dispatch_queue_t _BFNMQueue;
    void *_isOnBFNetworkManagerQueueKey;
}
@property(nonatomic, strong) BFNetworkSocket *socket;

@end

@implementation BFNetworkManager

#pragma mark - Setter && Getter

- (BFNetworkSocket *)socket {
    
    if (!_socket) {
        _socket = [BFNetworkSocket socket];
    }
    
    return _socket;
}

#pragma mark - Public

+ (instancetype)sharedInstance {
    
    static BFNetworkManager *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[BFNetworkManager alloc] init];
        [sharedInstance setupManagerQueue];
    });
    
    return sharedInstance;
}

- (void)connectToDefaultTargetServer {
    
    NSError *err;
    BOOL result = [self.socket connectToHost:testHost onPort:testPort error:&err];
    if (!result) {
        NSLog(@"链接服务器失败：%@", err);
    }
}

- (void)disconnectToDefaultTargetServer {
    
    [self.socket disconnect];
}

#pragma mark - Private

- (void)setupManagerQueue {
    
    _BFNMQueue = dispatch_queue_create([BFNetworkManagerQueueName UTF8String], NULL);
    _isOnBFNetworkManagerQueueKey = &_isOnBFNetworkManagerQueueKey;
    void *nonNullUnusedPointer = (__bridge void*)self;
    dispatch_queue_set_specific(_BFNMQueue, _isOnBFNetworkManagerQueueKey, nonNullUnusedPointer, NULL);
}

@end
