//
//  ViewController.m
//  NetEaseViedoDemo
//
//  Created by MKJING on 16/8/31.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import "ViewController.h"
#import <MJRefresh.h>
#import "MKJRequestHelper.h"
#import "ViedoModel.h"
#import "ViedoTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "WMPlayer.h"
#import "MKJRefreshHeader.h"
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kViedoURL @"http://c.m.163.com/nc/video/home/0-10.html"
#define kNavbarHeight ((kDeviceVersion>=7.0)? 64 :44 )
#define kIOS7DELTA   ((kDeviceVersion>=7.0)? 20 :0 )
#define kDeviceVersion [[UIDevice currentDevice].systemVersion floatValue]
#define kTabBarHeight 49

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,WMPlayerDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *viedoLists;
@property (nonatomic,strong) WMPlayer *wmPlayer; // 播放器View
@property (nonatomic,strong) NSIndexPath *currentIndexPath; // 当前播放的cell
@property (nonatomic,assign) BOOL isSmallScreen; // 是否放置在window上
@property(nonatomic,strong) ViedoTableViewCell *currentCell; // 当前cell

@end

static NSString *identify = @"ViedoTableViewCell";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:identify bundle:nil] forCellReuseIdentifier:identify];
    
    MKJRefreshHeader * header = [MKJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.mj_h = 80;
    self.tableView.mj_header = header;
    
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    
    footer.stateLabel.hidden = YES;
    self.tableView.mj_footer = footer;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header beginRefreshing];
    });
    
    
    
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange{
    if (self.wmPlayer==nil||self.wmPlayer.superview==nil){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            if (self.wmPlayer.isFullscreen) {
                if (self.isSmallScreen) {
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }
                else
                {
                    [self toCell];
                }
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在右");
            self.wmPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在左");
            self.wmPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        default:
            break;
    }
}


// 当前cell显示
-(void)toCell{
    
    
    ViedoTableViewCell *currentCell = (ViedoTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPath.row inSection:0]];
    // 每次切换的时候都要先移除掉
    [self.wmPlayer removeFromSuperview];
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        
        weakSelf.wmPlayer.transform = CGAffineTransformIdentity;
        //重新设置frame，重新设置layer的frame
        weakSelf.wmPlayer.frame = currentCell.mainImageView.bounds;
        weakSelf.wmPlayer.playerLayer.frame =  self.wmPlayer.bounds;
        [currentCell.mainImageView addSubview:weakSelf.wmPlayer];
        [currentCell.mainImageView bringSubviewToFront:weakSelf.wmPlayer];
        [weakSelf.wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.right.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(weakSelf.wmPlayer).with.offset(0);
        }];
        [weakSelf.wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.right.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.top.equalTo(weakSelf.wmPlayer).with.offset(0);
        }];
        [weakSelf.wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer.topView).with.offset(45);
            make.right.equalTo(weakSelf.wmPlayer.topView).with.offset(-45);
            make.center.equalTo(weakSelf.wmPlayer.topView);
            make.top.equalTo(weakSelf.wmPlayer.topView).with.offset(0);
        }];
        [weakSelf.wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(weakSelf.wmPlayer).with.offset(5);
        }];
        [weakSelf.wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.wmPlayer);
            make.width.equalTo(weakSelf.wmPlayer);
            make.height.equalTo(@30);
        }];
    }completion:^(BOOL finished) {
        weakSelf.wmPlayer.isFullscreen = NO;
        [weakSelf setNeedsStatusBarAppearanceUpdate];
        weakSelf.isSmallScreen = NO;
        weakSelf.wmPlayer.fullScreenBtn.selected = NO;
        
    }];
    
}


// 全屏显示
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    // 先移除
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        self.wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        self.wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    // 重新设置frame
    self.wmPlayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
   self.wmPlayer.playerLayer.frame =  CGRectMake(0,0, kScreenHeight,kScreenWidth);
    
    [self.wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(kScreenWidth-40);
        make.width.mas_equalTo(kScreenHeight);
    }];
    
    [self.wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        //        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenHeight);
    }];
    
    [self.wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.wmPlayer).with.offset((-kScreenHeight/2));
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.top.equalTo(self.wmPlayer).with.offset(5);
        
    }];
    
    [self.wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.wmPlayer.topView).with.offset(45);
        make.right.equalTo(self.wmPlayer.topView).with.offset(-45);
        make.center.equalTo(self.wmPlayer.topView);
        make.top.equalTo(self.wmPlayer.topView).with.offset(0);
    }];
    
    [self.wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenHeight);
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-36, -(kScreenWidth/2)));
        make.height.equalTo(@30);
    }];
    
    [self.wmPlayer.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-37, -(kScreenWidth/2-37)));
    }];
    [self.wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenHeight);
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-36, -(kScreenWidth/2)+36));
        make.height.equalTo(@30);
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:self.wmPlayer];
    
    self.wmPlayer.fullScreenBtn.selected = YES;
    [self.wmPlayer bringSubviewToFront:self.wmPlayer.bottomView];
    
}

// 滚动的时候小屏幕，放window上显示
-(void)toSmallScreen{
    //放widow上
    [self.wmPlayer removeFromSuperview];
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
       weakSelf.wmPlayer.transform = CGAffineTransformIdentity;
        // 设置window上的位置
        weakSelf.wmPlayer.frame = CGRectMake(kScreenWidth/2,kScreenHeight-kTabBarHeight + 40 -(kScreenWidth/2)*0.75, kScreenWidth/2, (kScreenWidth/2)*0.75);
        weakSelf.wmPlayer.playerLayer.frame =  weakSelf.wmPlayer.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.wmPlayer];
        [weakSelf.wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.right.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(weakSelf.wmPlayer).with.offset(0);
        }];
        [weakSelf.wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.right.equalTo(weakSelf.wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.top.equalTo(weakSelf.wmPlayer).with.offset(0);
        }];
        [weakSelf.wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer.topView).with.offset(45);
            make.right.equalTo(weakSelf.wmPlayer.topView).with.offset(-45);
            make.center.equalTo(weakSelf.wmPlayer.topView);
            make.top.equalTo(weakSelf.wmPlayer.topView).with.offset(0);
        }];
        [weakSelf.wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(weakSelf.wmPlayer).with.offset(5);
            
        }];
        [weakSelf.wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.wmPlayer);
            make.width.equalTo(weakSelf.wmPlayer);
            make.height.equalTo(@30);
        }];
        
    }completion:^(BOOL finished) {
        weakSelf.wmPlayer.isFullscreen = NO;
        [weakSelf setNeedsStatusBarAppearanceUpdate];
        weakSelf.wmPlayer.fullScreenBtn.selected = NO;
        weakSelf.isSmallScreen = YES;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:weakSelf.wmPlayer];
    }];
    
}


#pragma mark - 播放器的代理回调
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    NSLog(@"didClickedCloseButton");
    ViedoTableViewCell *currentCell = (ViedoTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPath.row inSection:0]];
    [currentCell.playButton.superview bringSubviewToFront:currentCell.playButton];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
    
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (fullScreenBtn.isSelected) {//全屏显示
        self.wmPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        if (self.isSmallScreen) {
            //放widow上,小屏显示
            [self toSmallScreen];
        }else{
            [self toCell];
        }
    }
}
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    NSLog(@"didSingleTaped");
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}

///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
    ViedoTableViewCell *currentCell = (ViedoTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPath.row inSection:0]];
    [currentCell.playButton.superview bringSubviewToFront:currentCell.playButton];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}

// 请求数据
- (void)refreshData
{
    __weak typeof(self)weakSelf = self;
    [[MKJRequestHelper shareHelper] getDataWithURLString:kViedoURL complete:^(NSError *err, id obj) {
       
        if (!err)
        {
            [weakSelf.viedoLists removeAllObjects];
            weakSelf.viedoLists = (NSMutableArray *)obj;
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }

    }];
}

// 加载更多
- (void)loadMore
{
    __weak typeof (self)weakSelf = self;
     NSString *URLString = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%u-10.html",arc4random() % 10];
    [[MKJRequestHelper shareHelper] getDataWithURLString:URLString complete:^(NSError *err, id obj) {
       
        if (!err)
        {
            NSInteger lastIndex = weakSelf.viedoLists.count;
            NSMutableArray *indexpaths = [NSMutableArray new];
            for (NSInteger i = 0; i < ((NSMutableArray *)obj).count; i ++)
            {
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastIndex inSection:0];
                lastIndex ++;
                [indexpaths addObject:indexpath];
            }
            [weakSelf.viedoLists addObjectsFromArray:((NSMutableArray *)obj)];
            [weakSelf.tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView.mj_footer endRefreshing];
            
        }
        
    }];
}

#pragma mark - 
#pragma mark - tableView的Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viedoLists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViedoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    
    [self configCell:cell indexpath:indexPath tableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configCell:(ViedoTableViewCell *)cell indexpath:(NSIndexPath *)indexpath tableView:(UITableView *)tableView
{
    ViedoModel *model = self.viedoLists[indexpath.row];
    cell.titleLabel.text = model.title;
    cell.descLabel.text = model.detailDes;
    cell.ptimeLabel.text = [model.ptime substringFromIndex:12];
    cell.playCountLabel.text = [NSString stringWithFormat:@"%lu",model.playCount];
    [cell.playButton addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playButton.tag = indexpath.row;
    __weak typeof(cell)weakCell = cell;
    [cell.mainImageView sd_setImageWithURL:[NSURL URLWithString:model.coverIMG] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
       
        if (image && cacheType == SDImageCacheTypeNone)
        {
            weakCell.mainImageView.alpha = 0;
            [UIView animateWithDuration:1.0 animations:^{
               
                weakCell.mainImageView.alpha = 1.0f;
                
            }];
        }
        else
        {
            weakCell.mainImageView.alpha = 1.0;
            
        }
    }];
    
    
    // 当播放器的View存在的时候
    if (self.wmPlayer&&self.wmPlayer.superview) {
        if (indexpath.row==self.currentIndexPath.row) {
            [cell.playButton.superview sendSubviewToBack:cell.playButton];
        }else{
            [cell.playButton.superview bringSubviewToFront:cell.playButton];
        }
        // 获取所有可见的cell的indexpaths
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        
        // 已经移除可见区域了
        if (![indexpaths containsObject:self.currentIndexPath]&&self.currentIndexPath!=nil) {//复用
            
            // 是否小窗口模式包含了
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:self.wmPlayer]) {
                self.wmPlayer.hidden = NO;
            }else{
                self.wmPlayer.hidden = YES;
                [cell.playButton.superview bringSubviewToFront:cell.playButton];
            }
        }else{ // 在可见区域以内 加到cell上面
            if ([cell.mainImageView.subviews containsObject:self.wmPlayer]) {
                [cell.mainImageView addSubview:self.wmPlayer];
                
                [self.wmPlayer play];
                self.wmPlayer.hidden = NO;
            }
            
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

#pragma mark - 播放器播放

- (void)startPlayVideo:(UIButton *)sender
{
    // 获取当前的indexpath
    self.currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    // iOS 7 和 8 以上获取cell的方式不同
    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
        self.currentCell = (ViedoTableViewCell *)sender.superview.superview;
    }else{//ios7系统 UITableViewCell上多了一个层级UITableViewCellScrollView
        self.currentCell = (ViedoTableViewCell *)sender.superview.superview.subviews;
    }
    ViedoModel *model = [self.viedoLists objectAtIndex:sender.tag];
    
    // 小窗口的时候点击播放另一个 先移除掉
    if (self.isSmallScreen) {
        [self releaseWMPlayer];
        self.isSmallScreen = NO;
        
    }
    // 当有上一个在播放的时候 点击 就先release
    if (self.wmPlayer) {
        [self releaseWMPlayer];
        self.wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.mainImageView.bounds];
        self.wmPlayer.delegate = self;
        self.wmPlayer.closeBtnStyle = CloseBtnStyleClose;
        self.wmPlayer.URLString = model.mp4URL;
        self.wmPlayer.titleLabel.text = model.title;
        //        [wmPlayer play];
    }else{
        // 当没有一个在播放的时候
        self.wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.mainImageView.bounds];
        self.wmPlayer.delegate = self;
        self.wmPlayer.closeBtnStyle = CloseBtnStyleClose;
        self.wmPlayer.titleLabel.text = model.title;
        self.wmPlayer.URLString = model.mp4URL;
    }
    // 把播放器加到当前cell的imageView上面
    [self.currentCell.mainImageView addSubview:self.wmPlayer];
    [self.currentCell.mainImageView bringSubviewToFront:self.wmPlayer];
    [self.currentCell.playButton.superview sendSubviewToBack:self.currentCell.playButton];
    [self.tableView reloadData];
}


#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.tableView){
        if (self.wmPlayer==nil) {
            return;
        }
        
        if (self.wmPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:self.currentIndexPath];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            if (rectInSuperview.origin.y<-self.currentCell.mainImageView.frame.size.height||rectInSuperview.origin.y>kScreenHeight-kNavbarHeight-kTabBarHeight) {//往上拖动
                
                if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:self.wmPlayer]&&self.isSmallScreen) {
                    self.isSmallScreen = YES;
                }else{
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }
                
            }else{
                if ([self.currentCell.mainImageView.subviews containsObject:self.wmPlayer]) {
                    
                }else{
                    [self toCell];
                }
            }
        }
        
    }
}


- (NSMutableArray *)viedoLists
{
    if (_viedoLists == nil) {
        _viedoLists = [[NSMutableArray alloc] init];
    }
    return _viedoLists;
}


/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [self.wmPlayer.player.currentItem cancelPendingSeeks];
    [self.wmPlayer.player.currentItem.asset cancelLoading];
    [self.wmPlayer pause];
    
    
    [self.wmPlayer removeFromSuperview];
    [self.wmPlayer.playerLayer removeFromSuperlayer];
    [self.wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    self.wmPlayer.player = nil;
    self.wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [self.wmPlayer.autoDismissTimer invalidate];
    self.wmPlayer.autoDismissTimer = nil;
    
    
    self.wmPlayer.playOrPauseBtn = nil;
    self.wmPlayer.playerLayer = nil;
    self.wmPlayer = nil;
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseWMPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
