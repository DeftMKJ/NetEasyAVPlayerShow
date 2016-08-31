//
//  MKJRequestHelper.h
//  NetEaseViedoDemo
//
//  Created by MKJING on 16/8/31.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completeBlock)(NSError *err,id obj);

@interface MKJRequestHelper : NSObject

+ (MKJRequestHelper *)shareHelper;


- (void)getDataWithURLString:(NSString *)urlStr complete:(completeBlock)completion;

@end
