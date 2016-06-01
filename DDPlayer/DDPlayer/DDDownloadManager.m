//
//  DDDownloadManager.m
//  DDPlayer
//
//  Created by 张德荣 on 16/5/24.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import "DDDownloadManager.h"

@interface DDDownloadManager () <NSCopying, NSURLSessionDelegate>
/** 保存所有任务(key--> url) */
@property (nonatomic, strong) NSMutableDictionary *tasks;
/** 保存所有下载相关信息字典 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;
/** 所有本地存储的所有下载信息数据数组 */
@property (nonatomic, strong) NSMutableArray *sessinModelsArray;
/** 下载完成的模型数组 */
@property (nonatomic, strong) NSMutableArray *downloadArray;
/** 下载中的模型数组 */
@property (nonatomic, strong) NSMutableArray *downloadingArray;

@end

@implementation DDDownloadManager
- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [[NSMutableDictionary alloc] init];
    }
    return _tasks;
}
- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = @{}.mutableCopy;
    }
    return _sessionModels;
}
- (NSMutableArray *)sessionModelsArray
{
    if (!_sessinModelsArray) {
        _sessinModelsArray =@[].mutableCopy;
        [_sessinModelsArray addObjectsFromArray:[self getSessionModels]];
    }
    return _sessinModelsArray;
}
static DDDownloadManager *_downloadManger;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManger = [super allocWithZone:zone];
    });
    return _downloadManger;
}
-(id)copyWithZone:(NSZone *)zone{
    return _downloadManger;
}
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManger = [[self alloc] init];
    });
    return _downloadManger;
}
/**
 归档
 */
- (void)save:(NSArray *)sessionModels{
    //文件信息
   [NSKeyedArchiver archiveRootObject:sessionModels toFile:DDDownloadDetailPath];
}
/**
 读取model
 */
- (NSArray *)getSessionModels {
    //文件信息
    NSArray *sessionModels = [NSKeyedUnarchiver unarchiveObjectWithFile:DDDownloadDetailPath];
    return sessionModels;
}
/**
 创建缓存目录文件
 */
- (void)createCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:DDCachesDirectory]) {
        [fileManager createDirectoryAtPath:DDCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}
- (void)download:(NSString *)url progress:(DDDownloadProgressBlock)progressBlock state:(DDDownloadStateBlock)stateBlock {
    //url为空
    if (!url) {
        return;
    }
    //已经下载过了
    if ([self isCompletion:url]) {
        stateBlock(DDSessionModelCompleted);
        NSLog(@"文件已经下载过");
        return;
    }
    
    //暂停
    if ([self.tasks valueForKey:DDFileName(url)]) {
        
    }
}
- (void)handle:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:url];
    } else {
        [self start:url];
    }
}
/**
 根据url获得对应的下线任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)url {
    return (NSURLSessionDataTask *)[self.tasks valueForKey:DDFileName(url)];
}
@end
