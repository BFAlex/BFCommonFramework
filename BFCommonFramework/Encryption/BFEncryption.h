//
//  BFEncryption.h
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>
//引入IOS自带密码库
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@interface BFEncryption : NSObject

#pragma 获得输入密码的MD5码
+(NSString*)md5_32:(NSString*)str;
+(NSString*)md5_16:(NSString*)str;


#pragma RBWP 协议解密/解密

+(NSString*)rbwpEncrypt:(NSString*)aInput;
+(NSData*)rbwpDecrypt:(NSData*)aInput;

@end
