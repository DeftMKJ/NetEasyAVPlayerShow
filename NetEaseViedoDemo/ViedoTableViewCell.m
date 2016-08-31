//
//  ViedoTableViewCell.m
//  NetEaseViedoDemo
//
//  Created by MKJING on 16/8/31.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import "ViedoTableViewCell.h"

@implementation ViedoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // 这东西不开，点击事件全没了
    self.mainImageView.userInteractionEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
