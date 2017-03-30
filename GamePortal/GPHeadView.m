//
//  GPHeadView.m
//  GamePortal
//
//  Created by 甘宏 on 3/28/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GPHeadView.h"

@implementation GPHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw a half circle
    UIColor *aColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    CGContextSetLineWidth(context, 3.0);
    CGContextAddArc(context, 100, 0, 70, 0, 2*PI, 1);
    CGContextDrawPath(context, kCGPathStroke);
    
    // draw another half circle
    UIColor *bColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, bColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddArc(context, 100, 0, 60, 0, 2*PI, 1);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 2 labels to display day & vote/kill time left;
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    l1.textAlignment = NSTextAlignmentCenter;
    l1.text = [NSString stringWithFormat:@"Day %@", _day];
    l1.center = CGPointMake(100, 15);
    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    l2.textAlignment = NSTextAlignmentCenter;
    l2.text = _sec;
    l2.center = CGPointMake(100, 50);
    
    [self addSubview:l1];
    [self addSubview:l2];
    
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _img.center = CGPointMake(100, 0);
    _img.layer.cornerRadius = 60;
    _img.layer.masksToBounds = YES;
    [_img setImage:[UIImage imageNamed:@"day_night"]];
    [self addSubview:_img];
}

- (void)layoutSubviews {
    
}

- (void)rotateImageView {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [_img setTransform:CGAffineTransformRotate(self.img.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished) {
            [self rotateImageView];
        }
    }];
}

- (void)showDayTime {
    [_img removeFromSuperview];
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _img.center = CGPointMake(100, 0);
    _img.layer.cornerRadius = 60;
    _img.layer.masksToBounds = YES;
    [_img setImage:[UIImage imageNamed:@"night"]];
    [self addSubview:_img];
}

- (void)showNightTime {
    [_img removeFromSuperview];
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _img.center = CGPointMake(100, 0);
    _img.layer.cornerRadius = 60;
    _img.layer.masksToBounds = YES;
    [_img setImage:[UIImage imageNamed:@"day"]];
    [self addSubview:_img];}

@end
