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
        [self handle:url];
        return;
    }
    
    //创建缓存目录文件
    [self createCacheDirectory];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:DDFileFullpath(url) append:YES];
    
    //创建请求
    NSMutableURLRequest *requset = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",DDDownloadLength(url)];
    [requset setValue:range forHTTPHeaderField:@"Range"];
    
    //创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requset];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKey:@"taskIdentifier"];
    //保存任务
    [self.tasks setValue:task forKey:DDFileName(url)];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:DDFileFullpath(url)]) {
        DDSessionModel *sessionModel = [[DDSessionModel alloc] init];
        sessionModel.url = url;
        sessionModel.progressBlock = progressBlock;
        sessionModel.stateBlock = stateBlock;
        sessionModel.stream = stream;
        sessionModel.starTime = [NSDate date];
        sessionModel.fileName = DDFileName(url);
        [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
        [self.sessionModelsArray addObject:sessionModel];
        [self.downloadingArray addObject:sessionModel];
        //保存
        [self save:self.sessionModelsArray];
    } else {
        for (DDSessionModel *sessionModel in self.sessionModelsArray) {
            if ([sessionModel.url isEqualToString:url]) {
                sessionModel.url = url;
                sessionModel.progressBlock = progressBlock;
                sessionModel.stateBlock = stateBlock;
                sessionModel.stream = stream;
                sessionModel.starTime = [NSDate date];
                sessionModel.fileName = DDFileName(url);
                [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
            }
        }
    }
    [self start:url];
    
    
    
    
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
 开始下载
 */
- (void)start:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    [task resume];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(DDSessionModelStart);
}
/**
 暂停下载
 */
- (void)pause:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(DDSessionModelSuspened);
}
/**
 根据url获得对应的下线任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)url {
    return (NSURLSessionDataTask *)[self.tasks valueForKey:DDFileName(url)];
}
/**
 根据url获得对象的下载模型
 */
- (DDSessionModel *)getSessionModel:(NSUInteger)taskIdentifier {
    return (DDSessionModel *)self.sessionModels[@(taskIdentifier).stringValue];
}
/**
 判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)url {
    return ([self fileTotalLength:url] && DDDownloadLength(url) == [self fileTotalLength:url]);
}
/**
 查询改资源的下载进度值
 */
- (CGFloat)progress:(NSString *)url {
    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * DDDownloadLength(url)/ [self fileTotalLength:url];
}
/**
 查询改资源的下载进度值
 */
- (NSInteger)fileTotalLength:(NSString *)url {
    for (DDSessionModel *model in self.sessionModelsArray) {
        if ([model.url isEqualToString:url]) {
            return model.totalLength;
        }
    }
    return 0;
}
@end
