//
//  MKJRequestHelper.m
//  NetEaseViedoDemo
//
//  Created by MKJING on 16/8/31.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import "MKJRequestHelper.h"
#import <AFHTTPSessionManager.h>
#import <MJExtension.h>
#import "ViedoModel.h"


@implementation MKJRequestHelper

+ (MKJRequestHelper *)shareHelper
{
    static MKJRequestHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
    
        helper = [[[self class] alloc] init];
    });
    return helper;
}

- (BOOL)isEmpty:(NSArray *)arr
{
    if (arr == nil || arr.count == 0)
    {
        return YES;
    }
    return NO;
}
- (NSString *)toJSONData:(NSDictionary *) dir
{
    if(!dir)
    {
        return @"";
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dir
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else
    {
        return @"";
    }
}

- (void)getDataWithURLString:(NSString *)urlStr complete:(completeBlock)completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response Json Data = %@",[self toJSONData:responseObject]);
        NSArray *arr = [responseObject valueForKey:@"videoList"];
        if (![self isEmpty:arr])
        {
            [ViedoModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
               
                return @{@"detailDes":@"description",
                         @"coverIMG":@"cover",
                         @"mp4URL":@"mp4Hd_url",
                         };
            }];
            
             NSMutableArray *viedoLists = [ViedoModel mj_objectArrayWithKeyValuesArray:arr];
            if (completion) {
                completion(nil,viedoLists);
            }
        }
        else
        {
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:@"未获取到数据" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:errorInfo];
            if (completion)
            {
                completion(error,nil);
            }
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"请求失败了%@",error);
        if (completion)
        {
            completion(error,nil);
        }
        
    }];
}

@end
