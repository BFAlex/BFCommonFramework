//
//  BFNetworkManager.h
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>

// 连接服务器状态
enum BFNetworkState {
    BFNetworkState_Disconnected,    // 未连接
    BFNetworkState_Connecting,      // 正在连接中...
    BFNetworkState_Reconnecting,    // 正在重连中...
    BFNetworkState_Connected,       // 已连接
    BFNetworkState_Authing,         // 正在授权验证中...
    BFNetworkState_Auth_Success,    // 验证成功
    BFNetworkState_Auth_Fail,       // 验证失败
    BFNetworkState_ReAuth_Fail,     // 重验证失败
};
typedef enum BFNetworkState BFNetworkState;

@interface BFNetworkManager : NSObject

+ (instancetype)sharedInstance;
- (void)connectToDefaultTargetServer;
- (void)disconnectToDefaultTargetServer;

- (void)loginDefaultAccount;

@end
