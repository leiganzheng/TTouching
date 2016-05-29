//
//  TrendChartView.h
//  QooccHealth
//
//  Created by qoocc04 on 14-9-5.
//  Copyright (c) 2014年 qoocc04. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrendChartViewDelegate <NSObject>

- (void)currentIndex:(NSInteger)score;

@end

// 图标上方两个切换按钮，是左边还是右边
typedef enum {
    left = 0,
    right
}TrendItemDirection;

typedef enum { // 图表类型
    kWeeklyTrend = 0, //周趋势图
    kMonthlyTrend,    //月趋势图
} chartType;

typedef enum {
    kHeartMeter = 0,//心电
    kHeartRate = 1,//脉率
    kBloodOxygen = 2,//血氧
    kBreathingRate = 3,//呼吸率
    kTemperature = 4,//体温
    kBloodPressure = 5,//血压
    kPissCheck = 6,//尿检
    kBloodSugar = 7,//血糖
    kPedometer = 8,//计步器
    kBloodPressureShrink = 9//收缩压
} CheckHistoryType;

#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
// 颜色值
// rgb
#define kCyColorFromRGBA(r, g, b, a) [UIColor colorWithRed:((r) / 255.0f) green:((g) / 255.0f) blue:((b) / 255.0f) alpha:(a)]
#define kCyColorFromRGB(r, g, b) [UIColor colorWithRed:((r) / 255.0f) green:((g) / 255.0f) blue:((b) / 255.0f) alpha:(1.0f)]


@interface TrendChartView : UIView

@property (nonatomic, strong) NSArray *sourceArray; // 作图的数据源，将服务器返回的传入即可
@property (nonatomic, assign) NSInteger curActiveIndex; // 当前活跃的index，即显示高亮显示的那个
@property (nonatomic, assign) TrendItemDirection itemDirection;
@property (nonatomic, assign) CheckHistoryType type; // 图表类型
@property (nonatomic, assign) CGFloat rowHeight; // 图表中每行的高度

@property (nonatomic, weak) UIViewController *viewController; // 关联的VC，vc的view是自身的superview
@property (nonatomic, weak) id <TrendChartViewDelegate> delegate;

@end
