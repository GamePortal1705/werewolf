//
//  GPCardView.m
//  GamePortal
//
//  Created by 甘宏 on 3/30/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GPCardView.h"

static CGFloat radius = 10;

static int shadowOffsetWidth = 0;
static int shadowOffsetHeight = 3;
static int shadowOpacity = 0.5;

@implementation GPCardView

- (void)layoutSubviews {
    self.layer.cornerRadius = radius;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    
    self.layer.masksToBounds = YES;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(shadowOffsetWidth, shadowOffsetHeight);
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowPath = shadowPath.CGPath;
    
    _imgV = [[UIImageView alloc] initWithFrame:self.bounds];
    [_imgV setImage:[UIImage imageNamed:@"back"]];
    [self addSubview:_imgV];
}


- (void)displayRole {
    switch (_role) {
        case 0:
            [_imgV setImage:[UIImage imageNamed:@"role1"]];
            break;
        case 1:
            [_imgV setImage:[UIImage imageNamed:@"role2"]];
            break;
        case 2:
            [_imgV setImage:[UIImage imageNamed:@"role3"]];
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
