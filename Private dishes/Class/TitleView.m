//
//  TitleView.m
//  单读
//
//  Created by mac on 16/2/5.
//  Copyright © 2016年 mac. All rights reserved.
//
//  自定义的导航栏视图

#import "TitleView.h"

@implementation TitleView {
    UILabel *label;
//    渐变的layer
    CAGradientLayer *layer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setLayer];
        label               = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        label.center        = self.center;
        label.origin        = CGPointMake(label.origin.x, label.origin.y + 10);
        label.textAlignment = NSTextAlignmentCenter;
        label.font          = [UIFont systemFontOfSize:18];
        label.textColor     = [UIColor whiteColor];
        label.text          = _title;
        [self addSubview:label];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _setLayer];
    label           = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    label.center    = self.center;
    label.origin    = CGPointMake(label.origin.x, label.origin.y + 10);
    label.textAlignment = NSTextAlignmentCenter;
    label.font          = [UIFont systemFontOfSize:18];
    label.textColor     = [UIColor whiteColor];
    label.text          = _title;
    [self addSubview:label];
}

//设置此导航栏是否半透明
- (void)setIsTranslucent:(BOOL)isTranslucent {
    if (!isTranslucent) {
        layer.locations = @[@0,@0];
        [layer removeFromSuperlayer];
    }
    else {
        layer.locations = @[@0,@1];
        [layer removeFromSuperlayer];
        [self _setLayer];
    }
}

- (void)setTitle:(NSString *)title {
    if (title != nil) {
        _title      = title;
        label.text  = _title;
    }
}

- (void)setLeftBarButton:(UIButton *)leftBarButton {
    if (leftBarButton) {
        _leftBarButton      = leftBarButton;
        leftBarButton.frame = CGRectMake(8, 22, 40, 40);
        if (_isLeftBtnRotation) {
            CABasicAnimation *rotationAnimation;
            rotationAnimation               = [CABasicAnimation animationWithKeyPath:@"transorm.rotation.z"];
            rotationAnimation.toValue       = [NSNumber numberWithFloat:M_PI*2.0];
            rotationAnimation.duration      = 1;
            rotationAnimation.cumulative    = YES;
            rotationAnimation.repeatCount   = 90;
            [leftBarButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        }
        [self addSubview:leftBarButton];
    }
}

- (void)setRightBarButton:(UIButton *)rightBarButton {
    if (rightBarButton) {
        _rightBarButton = rightBarButton;
        rightBarButton.frame = CGRectMake(PanScreenWidth - 48, 22, 40, 40);
        [self addSubview:rightBarButton];
    }
}

//设置渐变半透明效果
- (void)_setLayer {
    layer               = [CAGradientLayer layer];
    layer.frame         = self.bounds;
    layer.colors        = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.3].CGColor,(__bridge id)[UIColor colorWithWhite:0 alpha:0.01].CGColor];
    layer.startPoint    = CGPointMake(0, 0);
    layer.endPoint      = CGPointMake(0, 1);
    layer.locations     = @[@0,@1];
    [self.layer addSublayer:layer];
}

@end
