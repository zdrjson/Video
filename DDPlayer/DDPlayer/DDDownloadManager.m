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


@end
