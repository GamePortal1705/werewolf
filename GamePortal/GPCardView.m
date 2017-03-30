//
//  GPCardView.m
//  GamePortal
//
//  Created by 甘宏 on 3/30/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GPCardView.h"

static CGFloat radius = 2;

static int shadowOffsetWidth = 0;
static int shadowOffsetHeight = 3;
static int shadowOpacity = 0.5;

@implementation GPCardView

- (void)layoutSubviews {
    self.layer.cornerRadius = radius;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(shadowOffsetWidth, shadowOffsetHeight);
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowPath = shadowPath.CGPath;
    
    _imgV = [[UIImageView alloc] initWithFrame:self.bounds];
    [_imgV setImage:[UIImage imageNamed:@"back"]];
    [self addSubview:_imgV];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showImage {
}

@end
