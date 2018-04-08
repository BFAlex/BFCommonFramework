//
//  BFNetworkManager.h
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFNetworkManager : NSObject

+ (instancetype)sharedInstance;
- (void)connectToDefaultTargetServer;
- (void)disconnectToDefaultTargetServer;

@end
