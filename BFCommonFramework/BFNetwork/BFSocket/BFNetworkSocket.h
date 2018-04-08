//
//  BFNetworkSocket.h
//  BFCommonFramework
//
//  Created by BFAlex on 2018/4/8.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

// Define the timeouts (in seconds) for retreiving various parts of the Json stream
#define TIMEOUT_JSON_WRITE_STREAM   -1
#define TIMEOUT_JSON_READ_START     10
#define TIMEOUT_JSON_READ_STREAM    -1

// Define the tags we'll use to differentiate what it is we're currently reading or writing
#define TAG_JSON_READ_START         100
#define TAG_JSON_READ_STREAM        101
#define TAG_JSON_WRITE_START        200
#define TAG_JSON_WRITE_STREAM       201
#define TAG_JSON_WRITE_RECEIPT      202


@interface BFNetworkSocket : NSObject

+ (instancetype)socket;

// 连接与断开Server
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;
- (void)disconnect;
- (void)writeData:(NSData *)data;

@end
