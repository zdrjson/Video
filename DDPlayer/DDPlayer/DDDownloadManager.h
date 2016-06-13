//
//  DDDownloadManager.h
//  DDPlayer
//
//  Created by 张德荣 on 16/5/24.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDSessionModel.h"
// 缓存主目录
#define DDCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"DDCache"]
// 保存文件名
#define DDFileName(url) [[url componentsSeparatedByString:@"/"] lastObject]
// 文件的存放路径(caches)
#define DDFileFullpath(url) [DDCachesDirectory stringByAppendingPathComponent:DDFileName(url)]

#define DDDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:DDFileFullpath(url) error:nil][NSFileSize] integerValue]

//存储文件信息的路径(caches)
#define DDDownloadDetailPath [DDCachesDirectory stringByAppendingPathComponent:@"downloadDetail.data"]

@protocol DDDownloadDelegate <NSObject>
/** 下载中的回调 */
- (void)downloadResponse:(DDSessionModel *)sessionModel;

@end

@interface DDDownloadManager : NSObject
/** 保存所有下载相关信息字典 */
@property (nonatomic, strong, readonly) NSMutableDictionary *sessionModels;
/** 所有本地存储的所有下载信息数据数组 */
@property (nonatomic, strong, readonly) NSMutableArray *sessionModelsArray;
/** 下载完成的模型数组 */
@property (nonatomic, strong, readonly) NSMutableArray *downloadedArray;
/** 下载中的模型数组 */
@property (nonatomic, strong, readonly) NSMutableArray *downloadingArray;
/** DDDownloadDelegate */
@property (nonatomic, weak) id <DDDownloadDelegate> delegate;
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
/**
 查询该资源的下载进度值
 
 @param url 下载地址
 
 @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;
/**
 获取该资源总大小
 
 @param url 下载地址
 
 @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;
/**
 判断该资源是否下载完成
 
 @param url 下载地址
 
 @return 完成
 */
- (BOOL)isCompletion:(NSString *)url;
/**
 删除该资源
 
 @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;
/**
 清空所有下载资源
 */
- (void)deleteAllFile;
/**
 开始下载
 */
- (void)start:(NSString *)url;
/**
 暂停下载
 */
- (void)pause:(NSString *)url;
/**
 判断当前url是否正在下载
 
 @param url   视频url
 @param block 下载进度
 
 */
- (BOOL)isFileDownloadForUrl:(NSString *)url withProgressBlock:(DDDownloadProgressBlock)block;
/**
 正在下载的视频URL的数组
 
 @return 视频URL的数组
 */
- (NSArray *)currentDownloads;
@end
