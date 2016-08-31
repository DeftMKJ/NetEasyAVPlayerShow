//
//  ViedoTableViewCell.h
//  NetEaseViedoDemo
//
//  Created by MKJING on 16/8/31.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViedoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UILabel *ptimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playCountLabel;

@end
