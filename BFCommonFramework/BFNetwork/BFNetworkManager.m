//
//  BFNetworkManager.m
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import "BFNetworkManager.h"
#import "BFNetworkSocket.h"
#import "BFEncryption.h"

#import <UIKit/UIKit.h>

NSString *const BFNetworkManagerQueueName = @"BFNetworkManagerQueue";
// server(Test)
NSString *const testHost =@"120.25.120.222";
NSUInteger testPort = 8866;

//************************

// 登录协议 默认序号
NSString *const BFLoginOrder = @"Login";
NSString *const BFReconnectOrder = @"Reconect";

//************************


@interface BFNetworkManager () {
    // Queue
    dispatch_queue_t _BFNMQueue;
    void *_isOnBFNetworkManagerQueueKey;
}
@property(nonatomic, strong) BFNetworkSocket *socket;
@property(nonatomic, assign) BFNetworkState networkState;

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

- (void)loginDefaultAccount {
    
    NSString *account = @"18825155504";
    NSString *pwd = @"sbf000";
    
    [self authenticateWithUserName:account password:pwd err:nil];
}

#pragma mark - Private

- (void)setupManagerQueue {
    
    _BFNMQueue = dispatch_queue_create([BFNetworkManagerQueueName UTF8String], NULL);
    _isOnBFNetworkManagerQueueKey = &_isOnBFNetworkManagerQueueKey;
    void *nonNullUnusedPointer = (__bridge void*)self;
    dispatch_queue_set_specific(_BFNMQueue, _isOnBFNetworkManagerQueueKey, nonNullUnusedPointer, NULL);
}

/**
 *  JSON To NSData
 *
 *  @param object NSDictionary
 *
 *  @return NSData
 */
-(NSData*)jsonToData:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"dataTojsonString Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    //一行之内 每一条消息不能有\n
    //MESSAGE := JSONObject
    //消息内容使用 JSON 对象封装,JSONObject 中不能含有换行字符,即 CR、LF 字符。
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    
    
    NSString* entrypt = [BFEncryption rbwpEncrypt:jsonString];
    // LogInfo(@"SENDentrypt:%@",entrypt);
    //每条消息(MESSAGE)以换行符 \r\n 隔开
    //要先加密再加 换行符
    entrypt  = [entrypt stringByAppendingString:@"\r\n"];
    return [entrypt dataUsingEncoding:NSUTF8StringEncoding];
    
}

#pragma mark - Authenticate/Login

- (BOOL)authenticateWithUserName:(NSString *)username
                        password:(NSString *)pwd
                             err:(NSError **)err {
    
    NSString *password = [pwd copy];
    
    // 当前时间
    NSDate *currentDate = [NSDate date];
    // 当前时间对应的时间戳
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[currentDate timeIntervalSince1970]];
    // 消息序列号
    NSString *msgOrder = [self genetateMessageID:BFLoginOrder];
    
    NSMutableString *authStr = [[NSMutableString alloc] init];
    // 时间戳
    [authStr appendString:timeStamp];
    // MD5加密的密码
    [authStr appendString:[BFEncryption md5_16:password]];
    // 用户名
    [authStr appendString:username];
    // 消息序号
    [authStr appendString:msgOrder];
    // MD5转化
    NSString *authMD5 = [BFEncryption md5_16:authStr];
    
    return [self authenticateWithUsername:username auth:authMD5 stamp:timeStamp msgOrder:msgOrder uuid:nil error:err];
}

#pragma mark - Protocol

- (BOOL)authenticateWithUsername:(NSString *)username
                            auth:(NSString *)inAuth
                           stamp:(NSString *)stamp
                        msgOrder:(NSString *)order
                            uuid:(NSString *)uuid
                           error:(NSError **)err {
    
    __block BOOL result = YES;
    __block NSError *error = nil;
    
    NSString *authCopy = [inAuth copy];
    // 设备名
    NSString *deviceName = [[UIDevice currentDevice] name];
    if (!deviceName || deviceName.length <= 0) {
        deviceName = @"iphone";
    }
    
    dispatch_block_t block = ^{
        
        /*
         1、判断Socket是否已经连接
         2、判断是否正在登录
         3、判断所有参数是否有效
         **/
        
        // 所有条件成立
        // 设备ID
        NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        // 当前App版本号（假设为3.0.0）
        NSString *appVersion = @"3.0.0";
        // 登录协议
        NSMutableDictionary *loginJson = [[NSMutableDictionary alloc] init];
        [loginJson setObject:@"login" forKey:@"q"];         //协议请求
        [loginJson setObject:username forKey:@"username"];  //账号
        [loginJson setObject:authCopy forKey:@"auth"];          //授权码
        [loginJson setObject:stamp forKey:@"t"];            //时间戳
        [loginJson setObject:order forKey:@"o"];            //序号
        [loginJson setObject:deviceID forKey:@"device_id"];     //设备UUID,被挤下线用
        [loginJson setObject:deviceName forKey:@"device_name"];   //设备名,被挤下线用
        [loginJson setObject:appVersion forKey:@"v"];   //版本号
        if (uuid != nil){
            [loginJson setObject:uuid forKey:@"id"];   //家长用户ID
        }
        
        // 推送参数设置
        NSString *device_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"RBWP_DEVICE_TOKEN"];
        if (device_token) {
            [loginJson setObject:device_token forKey:@"device_token"];   //推送作用
        }
//        else{
//            LogError(@"device_token null!!!");
//        }
        
        // 把消息序号msgOrder放到消息池中
        // 增加超时判断
        
        // 给服务器发数据
        NSData *data = [self jsonToData:loginJson];
        // 标记状态
        [self.socket writeData:data];
        
    };
    
    if (dispatch_get_specific(_isOnBFNetworkManagerQueueKey)) {
        block();
    } else {
        dispatch_sync(_BFNMQueue, block);
    }
    
    return result;
}

/**
 产生消息ID，满足唯一性的前提下，传输要求，字符越少越好

 @param order <#order description#>
 @return <#return value description#>
 */
- (NSString *)genetateMessageID:(NSString *)order {
    
    NSString *msgID;
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    if (timeStamp.length > 6) {
        msgID = [timeStamp substringFromIndex:5];
    } else {
        msgID = timeStamp;
    }
    
    int randomValue = arc4random()%10;
    NSString *randomStr = [NSString stringWithFormat:@"%ld", (long)randomValue];
    msgID = [msgID stringByAppendingString:randomStr];
    
    if (order && ![order isEqualToString:@""]) {
        return [order stringByAppendingString:msgID];
    } else {
        return msgID;
    }
    
}

@end
