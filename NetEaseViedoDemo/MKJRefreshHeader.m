//
//  MKJRefreshHeader.m
//  MJRefresh
//
//  Created by MKJING on 16/8/22.
//  Copyright © 2016年 宓珂璟. All rights reserved.
//

#import "MKJRefreshHeader.h"
#import "XHJDRefreshView.h"

@interface MKJRefreshHeader ()

@property (nonatomic,strong) XHJDRefreshView *loadingView1;

@end

@implementation MKJRefreshHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (XHJDRefreshView *)loadingView1 {
    if (!_loadingView1) {
        _loadingView1 = [[XHJDRefreshView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
        [self addSubview:_loadingView1];
    }
    return _loadingView1;
}

// 重写代理，传偏移量
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    CGFloat new = -[change[@"new"] CGPointValue].y;
//    CGFloat old = -[change[@"old"] CGPointValue].y;
    NSLog(@"%@",[NSString stringWithFormat:@"%lf",new]);
    self.loadingView1.pullDownOffset = new > 55 ? 55 : new;
    
}

// 重写父类
- (void)placeSubviews
{
    [super placeSubviews];
    
    // 箭头的中心点
    CGFloat arrowCenterX = self.mj_w * 0.5;
    if (!self.stateLabel.hidden) {
        arrowCenterX -= 100;
    }
    CGFloat arrowCenterY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 箭头
    if (self.arrowView.constraints.count == 0) {
        self.arrowView.mj_size = self.arrowView.image.size;
        self.arrowView.center = arrowCenter;
    }
    
    // 圈圈
    if (self.loadingView1.constraints.count == 0) {
        self.loadingView1.center = arrowCenter;
    }
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    // 刷新完毕
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView1.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                self.loadingView1.alpha = 1.0;
                [self.loadingView1 endRefresing];
                self.arrowView.hidden = NO;
            }];
        } else { // 拉倒即将刷新的时候，又往回缩，不进行刷新
            [self.loadingView1 endRefresingDown];
            self.arrowView.hidden = NO;
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == MJRefreshStatePulling) { // 继续往下拉的时候
        [self.loadingView1 refreing];
        NSLog(@"连接点");
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    } else if (state == MJRefreshStateRefreshing) { // 刷新
        self.loadingView1.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView1 refreing];
        self.arrowView.hidden = YES;
    }
}


@end
