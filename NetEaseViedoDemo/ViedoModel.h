//
//  ViedoModel.h
//  NetEaseViedoDemo
//
//  Created by MKJING on 16/8/31.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViedoModel : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *detailDes;
@property (nonatomic,copy) NSString *coverIMG;
@property (nonatomic,copy) NSString *mp4URL;
@property (nonatomic,copy) NSString *ptime;
@property (nonatomic,assign) NSUInteger playCount;

@end
