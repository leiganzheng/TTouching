//
//  NSData+AES.h
//  QooccShow
//
//  Created by LeiGanZheng on 15/2/4.
//  Copyright (c) 2015年 Private. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author LeiGanZheng, 15-02-04
 *
 *  扩展对 NSData 进行 AES128 加密 || 解密
 *    会先对密钥进行MD5加密，取前32位作为AES128加密的密钥
 */
@interface NSData (AES)

// 加密
- (NSData *)encrypt:(NSString *)key;
// 解密
- (NSData *)decrypt:(NSString *)key;

@end
