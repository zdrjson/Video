//
//  DDDownloadManager.h
//  DDPlayer
//
//  Created by 张德荣 on 16/5/24.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDSessionModel.h"

@interface DDDownloadManager : NSObject
/** 保存所有下载相关信息字典 */
@property (nonatomic, strong, readonly) NSMutableDictionary *sessionModels;
/** 所有本地存储的所有下载信息数据数组 */
@property (nonatomic, strong, readonly) NSMutableArray *sessionModelsArray;
/** 下载完成的模型数组 */
@property (nonatomic, strong, readonly) NSMutableArray *downloadArray;
/** 下载中的模型数组 */
@property (nonatomic, strong, readonly) NSMutableArray *downloadingArray;
/**
 单例
 
 @return 返回单例对象
 */
+ (instancetype)shareInstance;
/**
 归档
 */
- (void)save:(NSArray *)sessionModels;
/**
 读取model
 */
- (NSArray *)getSessionModels;
/**
 开启任务下载资源
 
 @param url           下载地址
 @param progressBlock 回调下载进度
 @param stateBlock    下载状态
 */
- (void)download:(NSString *)url
        progress:(DDDownloadProgressBlock)progressBlock
           state:(DDDownloadStateBlock)stateBlock;
@end
