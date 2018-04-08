//
//  BFNetworkSocket.m
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import "BFNetworkSocket.h"
#import <GCDAsyncSocket.h>  // for TCP
//#import <GCDAsyncUdpSocket.h> // for UDP

NSString *const BFNetworkSocketQueueName = @"BFNetworkSocketQueue";

@interface BFNetworkSocket ()<GCDAsyncSocketDelegate> {
    
    GCDAsyncSocket *_asyncSocket;
    
    // Queue
    dispatch_queue_t _networkSocketQueue;
    void *_isOnBFNetworkSocketQueueKey;
}

@end

@implementation BFNetworkSocket

#pragma mark - Public

+ (instancetype)socket {
    
    BFNetworkSocket *networkSocket = [[BFNetworkSocket alloc] init];
    if (networkSocket) {
        
        [networkSocket setupAsyncSocket];
    }
    
    return networkSocket;
}

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr {
    
    // 连接前需要断开就连接
    if (_asyncSocket.isConnected) {
        [_asyncSocket disconnect];
    }
    
    return [_asyncSocket connectToHost:host onPort:port error:errPtr];
}

- (void)disconnect {
    
    [_asyncSocket disconnect];
    NSLog(@"主动断开服务器连接");
}

- (void)writeData:(NSData *)data {
    
    [_asyncSocket writeData:data withTimeout:TIMEOUT_JSON_WRITE_STREAM tag:TAG_JSON_READ_STREAM];
}

#pragma mark - Private
#pragma mark Queue
- (void)setupNetworkSocketQueue {
    
    _networkSocketQueue = dispatch_queue_create([BFNetworkSocketQueueName UTF8String], NULL);
    _isOnBFNetworkSocketQueueKey = &_isOnBFNetworkSocketQueueKey;
    void *nonNullUnusedPointer = (__bridge void*)self;
    dispatch_queue_set_specific(_networkSocketQueue, _isOnBFNetworkSocketQueueKey, nonNullUnusedPointer, NULL);
}
#pragma mark Socket
- (void)setupAsyncSocket {
    
    [self setupNetworkSocketQueue];
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_networkSocketQueue];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect -> err:%@", err);
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost(host:%@, port:%d)", host, port);
    
    // 开始读数据
    [_asyncSocket readDataWithTimeout:TIMEOUT_JSON_READ_STREAM tag:TAG_JSON_READ_STREAM];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData:%@, tag:%ld", data, tag);
    
    // 持续读数据
    [_asyncSocket readDataWithTimeout:TIMEOUT_JSON_READ_STREAM tag:TAG_JSON_READ_STREAM];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag -> tag: %ld", tag);
}

@end
