//
//  XHJDRefreshView.h
//  XHRefreshControlExample
//


#import <UIKit/UIKit.h>

@interface XHJDRefreshView : UIView

@property (nonatomic, assign) CGFloat pullDownOffset;

- (void)willRefresh;

- (void)refreing;

- (void)endRefresing;

- (void)normal;

- (void)endRefresingDown;

@end
