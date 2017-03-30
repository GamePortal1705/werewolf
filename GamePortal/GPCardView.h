//
//  GPCardView.h
//  GamePortal
//
//  Created by 甘宏 on 3/30/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPCardView : UIView

@property (strong, nonatomic) UIImageView *imgV;
@property int role;

- (void)displayRole;

@end
