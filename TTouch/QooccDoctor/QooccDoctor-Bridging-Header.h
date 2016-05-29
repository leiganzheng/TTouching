//
//  QooccDoctor-Bridging-Header.h
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/3.
//  Copyright (c) 2015年 Qoocc. All rights reserved.
//

#ifndef QooccDoctor_QooccDoctor_Bridging_Header_h
#define QooccDoctor_QooccDoctor_Bridging_Header_h

#import <CommonCrypto/CommonDigest.h>   // MD5 相关需要
#import <CommonCrypto/CommonCryptor.h>  // AES加密解密 相关需要
#import "NSString+AES.h"                // AES 加密解密 相关需要

#import <QuartzCore/QuartzCore.h>
#import <REMenu/REMenuItem.h>
#import <REMenu/REMenu.h>
#import "SUNButtonBoard.h"
#import "KDGoalBar.h"
#import "TrendChartView.h"
#import "PedometerProgressView.h"
#import "CBChartView.h"
#import "PNLineChartView.h"
#import "PNPlot.h"

#import <OpenUDID/OpenUDID.h>

//BEGIN 网络图片加载库
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImageView+HighlightedWebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCacheOperation.h>
//END
#import "MobClick.h"            // 友盟统计
#import <IQKeyboardManager/IQKeyboardManager.h> // 解决键盘被挡住的问题
#import "APService.h"           // 极光推送

//环信SDK头文件（包含实时语音版本的SDK）
#import <EaseMobSDKFull/EaseMob.h>
#import <EaseMobSDKFull/EMChatVideo.h>
#import <EaseMobSDKFull/OpenGLView20.h>
#import "CallViewController.h"
#endif
