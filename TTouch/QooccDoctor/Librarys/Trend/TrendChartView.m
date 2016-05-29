//
//  TrendChartView.m
//  QooccHealth
//
//  Created by qoocc04 on 14-9-5.
//  Copyright (c) 2014年 qoocc04. All rights reserved.
//

#import "TrendChartView.h"

// 下三个依次为图表距离给定Frame的上边距，左边距，下边距，图表并不在给定Frame区域完整作图
const NSInteger topMargin = 10;
const NSInteger leftMargin = 20;
const NSInteger bottomMargin = 45;

const NSInteger columnWidth = 40; // 列宽
const NSInteger OuterRadius = 6;  // 高亮圆半径
const NSInteger InnerRadius = 3;  // 普通点半径

// 依次为蓝，绿，黄线的颜色
#define kGreenLineColor kCyColorFromRGB(0, 153, 255)
#define kBlueLineColor kCyColorFromRGB(3, 157, 86)
#define kYellowLineColor kCyColorFromRGB(255, 170, 0)

#define kGridLineColor kCyColorFromRGB(242, 242, 242) // 普通坐标线的颜色
#define kDateLabelTextColor kCyColorFromRGB(196, 196, 196) // 普通日期Label文字颜色
#define kActiveDateLabelTextColor kCyColorFromRGB(102, 102, 102) // 高亮日期Label文字颜色
#define kActiveGridLineColor kCyColorFromRGB(177, 177, 177) // 高亮坐标线的颜色


@interface TrendChartView ()

@property (nonatomic, assign) CGFloat chartHeight; // 图表实际绘图高度

@property (nonatomic, strong) NSArray *valueArray; // 图标左侧坐标值来源

// 以下五个可变数组，是处理SourceArray后的结果，分别为日期，得分，早晨的点，下午的点，晚上的点
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSMutableArray *scoreArray;
@property (nonatomic, strong) NSMutableArray *morningArray;
@property (nonatomic, strong) NSMutableArray *afternoonArray;
@property (nonatomic, strong) NSMutableArray *nightArray;

// 本数组再每次更新SourceArray之后，将上面五个处理结果封装在一起
@property (nonatomic, strong) NSArray *allMeasureValueArray;

// 以下三个可变数组，分别是早晨的点，下午的点，晚上的点，单个元素的值为CGPoint的NSValue封装
@property (nonatomic, strong) NSMutableArray *morningPointArray;
@property (nonatomic, strong) NSMutableArray *afternoonPointArray;
@property (nonatomic, strong) NSMutableArray *nightPointArray;

// 本数组将上面三个处理结果封装在一起
@property (nonatomic, strong) NSArray *allPointArray;

@end

@implementation TrendChartView

- (void)setItemDirection:(TrendItemDirection)itemDirection {
    _itemDirection = itemDirection;
//    if (_viewController && [_viewController respondsToSelector:@selector(updateValueLabelView)]) {
//        [_viewController updateValueLabelView];
//    }
}

- (void)setCurActiveIndex:(NSInteger)curActiveIndex {
    // 容错
    if ((curActiveIndex >= 0) && (curActiveIndex < _sourceArray.count)) {
        _curActiveIndex = curActiveIndex;
    }
    // 通知VC更新得分结果，模式和delegate相同，只不过未使用delegate
    if ([self.delegate respondsToSelector:@selector(currentIndex:)]) {
        [self.delegate currentIndex:((NSNumber *)_scoreArray[_curActiveIndex]).integerValue];
    }
}

- (void)setSourceArray:(NSArray *)sourceArray {
    [self updateSourceArrayWithSource:sourceArray];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        _itemDirection = left; // 默认为左边
        _chartHeight = frame.size.height - topMargin - bottomMargin;
                
        _valueArray = @[@[@[@"30",@"60",@"90",@"120"], @[@"5",@"10",@"20",@"30"]],// 心电图
                                @[@[@"30",@"60",@"90",@"120"]],// 脉率
                                @[@[@"70%",@"80%",@"90%",@"100%",@"110%",@"120%"]], // 血氧
                                @[@[@"5",@"10",@"15",@"20",@"25",@"30",@"35",@"40"]], // 呼吸率
                                @[@[@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42"]], // 体温
                                @[@[@"30",@"60",@"90",@"120"]],// 血压（舒张压）
                                @[@[@"0",@"20",@"40",@"60",@"80",@"100"]], // 尿检
                                @[@[@"0",@"5.0",@"10.0",@"15.0",@"20.0",@"25.0",@"30.0",@"35.0"]],//血糖
                                @[@[@"0",@"1000",@"2000",@"3000",@"4000",@"5000",@"6000",@"7000"]], // 计步器
                                @[@[@"60",@"80",@"100",@"120", @"140", @"160",@"180",@"200"]]//收缩压（高压）
                        ];

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (_sourceArray) {
        [self configHeightForPoint];
        [self drawGridLine];
        [self drawLine];
        [self drawCircle];
        [self addDateLabel];
    }
    
}

#pragma mark - preparation For Drawing

/**
 *  更新SourceArray，数据进行更新
 *
 *  @param sourceArray 新数据源
 */
- (void)updateSourceArrayWithSource:(NSArray *)sourceArray {
    // 移除上次的Label,避免残影
    for (UILabel *tmp in self.subviews) {
        [tmp removeFromSuperview];
    }
    
    _sourceArray = sourceArray;
    _morningArray = [NSMutableArray array];
    _afternoonArray = [NSMutableArray array];
    _nightArray = [NSMutableArray array];
    _dateArray = [NSMutableArray array];
    _scoreArray = [NSMutableArray array];
    _allMeasureValueArray = @[_morningArray, _afternoonArray, _nightArray, _dateArray, _scoreArray];
    
    CGRect rect = self.frame;
    rect.size = CGSizeMake((_sourceArray.count + 7) * columnWidth, rect.size.height);
    self.frame = rect;
    
    // 接口中相关字段
    NSArray *keyStringArray = @[@"morning", @"afternoon", @"night", @"date", @"score"];
    for (int i = 0; i < _sourceArray.count; i++) {
        // 对数组中每项数据进行分析
        for (int j = 0; j < _allMeasureValueArray.count; j++) {
            NSString *tmpStr = [NSString stringWithFormat:@"%@", _sourceArray[i][keyStringArray[j]]];
            
            // 如果是第四项，下标为3，则是日期结果，不用NSValue封装，直接添加到数组中
            if (j != 3) {
                [_allMeasureValueArray[j] addObject:[NSNumber numberWithFloat:tmpStr.floatValue]];
            } else {
                [_allMeasureValueArray[3] addObject:tmpStr];
            }
            
        }
    }
    // 更新scrollview的contentsize
    ((UIScrollView *)(self.superview)).contentSize = CGSizeMake(columnWidth * (_sourceArray.count + 6), 0);
}

/**
 *  为每个点计算他的具体坐标并使用NSValue封装
 */
- (void)configHeightForPoint {
    // 置空
    _morningPointArray = [NSMutableArray array];
    _afternoonPointArray = [NSMutableArray array];
    _nightPointArray = [NSMutableArray array];
    _allPointArray = @[_morningPointArray, _afternoonPointArray, _nightPointArray];
    
    CGFloat yoffset = 0.0;
    // 当前图标类型下，坐标左边刻度值的个数
    NSArray *array = _valueArray[_type];
    NSInteger count = [array[_itemDirection] count];
    // 最大值和最小值
    CGFloat minValue = ((NSNumber *)array[_itemDirection][0]).floatValue;
    CGFloat maxValue = ((NSNumber *)array[_itemDirection][count - 1]).floatValue;
    
    for (int i = 0; i < _allPointArray.count; i++) {
        for (int j = 0; j < _sourceArray.count; j++) {
            CGFloat value = ((NSNumber *)_allMeasureValueArray[i][j]).floatValue;
            // 无效值服务器返回为-1，这里进行判断
            if (value > -.5) {
                // 容错，如果服务器返回的值异常，大于最大值，则取最大值
                if (value >= maxValue) {
                    yoffset = topMargin;
                } else if (value < minValue) {
                    yoffset = topMargin + _chartHeight;
                } else {
                    yoffset = (maxValue - value)/(maxValue - minValue) * _chartHeight + topMargin;
                }
                
                CGPoint point = CGPointMake(columnWidth * j + leftMargin, yoffset);
                NSValue *pointValue = [NSValue valueWithCGPoint:point];
                [_allPointArray[i] addObject:pointValue];
            }
        }
    }
}

#pragma mark - Label stuff

/**
 *  添加日期Label
 */
- (void)addDateLabel {
    // 移除上次的Label,残影
    for (UILabel *tmp in self.subviews) {
        [tmp removeFromSuperview];
    }
    for (int i = 0; i < _dateArray.count; i++) {
        // 格式化时间
        NSString *tmpStr = _dateArray[i];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *date = [formatter dateFromString:tmpStr];
        formatter.dateFormat = @"M-d";
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 18)];
        label.textAlignment = NSTextAlignmentCenter;
        
        // 高亮则显示高亮色
        label.textColor = (i == _curActiveIndex) ? kActiveDateLabelTextColor : kDateLabelTextColor;
        
        label.font = [UIFont systemFontOfSize:15];
        label.text = [formatter stringFromDate:date];
        label.center = CGPointMake(leftMargin + columnWidth * i, self.bounds.size.height - bottomMargin/2 - 5);
        
        [self addSubview:label];
    }
}

#pragma mark - CG methods

/**
 *  画坐标线
 */
- (void)drawGridLine {
    // 横向
    NSInteger count = [_valueArray[_type][_itemDirection] count];
    self.rowHeight = _chartHeight / (count - 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 横向灰线
    for (int i = 0; i < count; i++) {
        NSInteger pointY = topMargin + _rowHeight * i;
        CGContextSetStrokeColorWithColor(context, kGridLineColor.CGColor);
        CGContextMoveToPoint(context, leftMargin, pointY);
        
        CGContextAddLineToPoint(context, (_sourceArray.count + 6) * columnWidth, pointY);
        CGContextStrokePath(context);
    }
    
    // 纵向灰线
    for (int i = 0 ; i < _sourceArray.count + 6; i++) {
        NSInteger pointX = leftMargin + columnWidth * i;
        
        // 高亮则用高亮颜色
        CGContextSetStrokeColorWithColor(context, (i == _curActiveIndex) ? kActiveGridLineColor.CGColor : kGridLineColor.CGColor);
        
        CGContextMoveToPoint(context, pointX, topMargin);
        CGContextAddLineToPoint(context, pointX, self.bounds.size.height - bottomMargin);
        CGContextStrokePath(context);
    }
}

/**
 *  连接各点之间的连线
 */
- (void)drawLine {
    NSArray *colorArray = @[kBlueLineColor, kYellowLineColor, kGreenLineColor];
    for (int i = 0; i < _allPointArray.count; i++) {
        // 依次处理早中晚的线
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, ((UIColor *)colorArray[i]).CGColor);
        // _allPointArray[i]为选取早，中，晚的点数组，_allPointArray[i].count则是各自的点的个数
        for (int j = 0; j < ((NSMutableArray *)_allPointArray[i]).count; j++) {
            CGPoint point = ((NSValue *)_allPointArray[i][j]).CGPointValue;
            // 第一个点则是CG移动到该点，其他情况则是连线
            if (j == 0) {
                CGContextMoveToPoint(context, point.x, point.y);
            } else {
                CGContextAddLineToPoint(context, point.x, point.y);
            }
        }
        CGContextStrokePath(context);
    }
}

/**
 *  每个点上画圆
 */
- (void)drawCircle {
    NSArray *colorArray = @[kBlueLineColor, kYellowLineColor, kGreenLineColor];
    CGFloat alpha = .4;
    NSArray *activeColorArray = @[kCyColorFromRGBA(3, 157, 86, alpha), kCyColorFromRGBA(255, 170, 0, alpha),  kCyColorFromRGBA(0, 153, 255, alpha)];
    for (int i = 0; i < _allPointArray.count; i++) {
        for (int j = 0; j < ((NSMutableArray *)_allPointArray[i]).count; j++) {
            CGPoint point = ((NSValue *)_allPointArray[i][j]).CGPointValue;
            [self drawCircleAtPoint:point WithColor:colorArray[i] AndRadius:InnerRadius];
            // 判断是否为高亮
            if (point.x == (leftMargin + columnWidth * _curActiveIndex)) {
                [self drawCircleAtPoint:point WithColor:activeColorArray[i] AndRadius:OuterRadius];
            }
        }
    }
}

/**
 *  在某个点画圆
 *
 *  @param point  圆心
 *  @param color  填充色
 *  @param radius 半径
 */
- (void)drawCircleAtPoint:(CGPoint)point WithColor:(UIColor *)color AndRadius:(CGFloat)radius {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, point.x, point.y);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddArc(context, point.x, point.y, radius, 0, M_PI*2, 0);
    CGContextDrawPath(context, kCGPathFill);
}

@end
