//
//  GetWiFiInfoHelper.h
//  GetWiFiInfo_Demo
//
//  Created by admin on 16/6/20.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN        @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface GetWiFiInfoHelper : NSObject


//获取当前连接Wi-Fi名称与MAC地址
+(id)fetchSSIDInfo;

//获取当前连接Wi-Fi的IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
@end
