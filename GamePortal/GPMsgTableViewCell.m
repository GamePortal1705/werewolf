//
//  GPMsgTableViewCell.m
//  GamePortal
//
//  Created by 甘宏 on 3/26/17.
//  Copyright © 2017 edu.self. All rights reserved.
//

#import "GPMsgTableViewCell.h"

@implementation GPMsgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_msg setFont:[UIFont fontWithName:@"Courier New-Bold" size:16]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
