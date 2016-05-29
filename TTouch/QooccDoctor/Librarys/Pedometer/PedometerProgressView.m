//
//  PedometerProgressView.m
//  QooccHealth
//
//  Created by qoocc04 on 14-8-28.
//  Copyright (c) 2014年 qoocc04. All rights reserved.
//

#import "PedometerProgressView.h"

@interface PedometerProgressView()
@property (nonatomic, strong) CAGradientLayer *backgroundGradientLayer;
@end

@implementation PedometerProgressView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 生成一个彩色的图片
        [self setupGradientBackground];
        _percentage = 0.f;
    }
    return self;
}

- (void)setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    self.layer.mask = [self setupMaskLayer];
    [self startAnimation];
}

- (void)setupGradientBackground {
    _backgroundGradientLayer = [[CAGradientLayer alloc] init];
    _backgroundGradientLayer.frame = self.bounds;
    _backgroundGradientLayer.contents = (id)[UIImage imageNamed:@"Pedometer_circularBG"].CGImage;
    [self.layer addSublayer:_backgroundGradientLayer];
}

- (CAShapeLayer *)setupMaskLayer {
    // 生产出一个圆的路径
    int circlePointOffset = 0;
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - circlePointOffset);
    CGFloat circleRadius = self.bounds.size.width/2 - 5;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:circleCenter
                                                              radius:circleRadius
                                                          startAngle:M_PI+0.09
                                                            endAngle:M_PI*3
                                                           clockwise:YES];
    
    // 生产出一个圆形路径的Layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = circlePath.CGPath;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineWidth = 10;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.strokeEnd = _percentage;
    
    return shapeLayer;
}

- (void)startAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1.5;
    animation.fromValue = @0;
    animation.toValue = [NSNumber numberWithFloat:_percentage];
    [self.layer.mask addAnimation:animation forKey:@"strokeEnd"];
}

- (void)endAnimation
{
    [self.layer.mask removeAllAnimations];
}

@end
