//
//  BFNetworkSocket.h
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFNetworkSocket : NSObject

+ (instancetype)socket;

- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;
- (void)disconnect;

@end
