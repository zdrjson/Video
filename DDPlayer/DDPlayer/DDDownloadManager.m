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
@property (nonatomic, strong) NSMutableArray *sessionModelsArray;
/** 下载完成的模型数组 */
@property (nonatomic, strong) NSMutableArray *downloadedArray;
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
    if (!_sessionModelsArray) {
        _sessionModelsArray =@[].mutableCopy;
        [_sessionModelsArray addObjectsFromArray:[self getSessionModels]];
    }
    return _sessionModelsArray;
}
- (NSMutableArray *)downloadedArray
{
    if (!_downloadedArray) {
        _downloadedArray = @[].mutableCopy;
        for (DDSessionModel *obj in self.sessionModelsArray) {
            if ([self isCompletion:obj.url]) {
                [_downloadedArray addObject:obj];
            }
        }
    }
    return _downloadedArray;
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
#pragma mark - 删除
- (void)deleteFile:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    if (task) {
        //取消下载
        [task cancel];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:DDFileFullpath(url)]) {
        //删除沙盒中的资源
        [fileManager removeItemAtPath:DDFileFullpath(url) error:nil];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:DDDownloadDetailPath]) {
            // 从沙盒中移除该条模型的信息
            for (DDSessionModel *model in self.sessionModelsArray.mutableCopy) {
                if ([model.url isEqualToString:url]) {
                    //关闭流
                    [model.stream close];
                    [self.sessionModelsArray removeObject:model];
                }
            }
        }
    }
}
/**
 清空所有下载资源
 */
- (void)deleteAllFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:DDCachesDirectory]) {
        
        //删除沙盒中所有资源
        [fileManager removeItemAtPath:DDCachesDirectory error:nil];
        //删除任务
        [self.tasks.allValues makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        for (DDSessionModel *sessionModel in self.sessionModels.allValues) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        //删除资源总长度
        if ([fileManager fileExistsAtPath:DDDownloadDetailPath]) {
            [fileManager removeItemAtPath:DDDownloadDetailPath error:nil];
            [self.sessionModelsArray removeAllObjects];
            self.sessionModelsArray = nil;
            [self.downloadedArray removeAllObjects];
            [self.downloadingArray removeAllObjects];
        }
        
    }
}
- (BOOL)isFileDownloadForUrl:(NSString *)url withProgressBlock:(DDDownloadProgressBlock)block {
    BOOL retValue = NO;
    NSURLSessionDataTask *task = [self getTask:url];
    DDSessionModel *session = [self getSessionModel:task.taskIdentifier];
    if (session) {
        if (block) {
            session.progressBlock = block;
        }
        retValue = YES;
    }
    return retValue;
}

- (NSArray *)currentDownloads {
    NSMutableArray *currentDownloads = [NSMutableArray new];
    [self.sessionModels enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, DDSessionModel *obj, BOOL * _Nonnull stop) {
        [currentDownloads addObject:obj.url];
    }];
    return currentDownloads;
}
#pragma mark NSURLSessionDataDelegate

// 接受到响应
/**
 - (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    DDSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    //打开流
    [sessionModel.stream open];
    //获得服务器这次请求返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + DDDownloadLength(sessionModel.url);
    sessionModel.totalLength = totalLength;
    
    //总文件大小
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",[sessionModel calculateFieSizeInUnit:(unsigned long long)totalLength],[sessionModel calculateUnit:(unsigned long long)totalLength]];
    sessionModel.totalSize = fileSizeInUnits;
    //更新数据(文件总长度)
    [self save:self.sessionModelsArray];
    
    //添加下载中数组
    if (![self.downloadingArray containsObject:sessionModel]) {
        [self.downloadingArray addObject:sessionModel];
    }
    
    //接受这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}
/**
 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    DDSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    //写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    //下载进度
    NSUInteger receivedSize = DDDownloadLength(sessionModel.url);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    //每秒下载速度
    NSTimeInterval downloadTime = -1 * [sessionModel.starTime timeIntervalSinceNow];
    NSLog(@"%f",downloadTime);
    NSUInteger speed = receivedSize / downloadTime;
    if (speed == 0)  return ;
    float speedSec = [sessionModel calculateFieSizeInUnit:(unsigned long long)speed];
    NSString *unit = [sessionModel calculateUnit:(unsigned long long)speed];
    NSString *speedStr = [NSString stringWithFormat:@"%.2f%@/s",speedSec,unit];
    
    //剩余下载时间
    NSMutableString *remainingTimeStr = [[NSMutableString alloc] init];
    unsigned long long remainingContentLength = expectedSize - receivedSize;
    int remainingTime = (int)(remainingContentLength / speed);
    int hours = remainingTime / 3600;
    int minutes = (remainingTime - hours * 3600) / 60;
    int seconds = remainingTime - hours * 3600 -minutes * 60;
    
    if (hours > 0) {
        [remainingTimeStr appendFormat:@"%d 小时",hours];
         [remainingTimeStr appendFormat:@"%d 分",minutes];
         [remainingTimeStr appendFormat:@"%d 秒",seconds];
    }
    
    NSString *writtenSize = [NSString stringWithFormat:@"%.2f %@",[sessionModel calculateFieSizeInUnit:(unsigned long long)receivedSize], [sessionModel calculateUnit:(unsigned long long)receivedSize]];
    
    if (sessionModel.stateBlock) {
        sessionModel.stateBlock(DDSessionModelStart);
    }
    
    if (sessionModel.progressBlock) {
        sessionModel.progressBlock(progress, speedStr, remainingTimeStr, writtenSize, sessionModel.totalSize);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downloadResponse:)]) {
            [self.delegate downloadResponse:sessionModel];
        }
    });
}
/*
 *  请求成功（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    DDSessionModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel)  return ;
    
    //关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    if ([self isCompletion:sessionModel.url]) {
        //下载完成
        sessionModel.stateBlock(DDSessionModelCompleted);
    } else if (error) {
        //下载失败
        sessionModel.stateBlock(DDSessionModelFailed);
    }
    
    //清除任务
    [self.tasks removeObjectForKey:DDFileName(sessionModel.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    [self.downloadingArray removeObject:sessionModel];
    
    if (error.code == -999) {
        return;  // cancel
    }
    
    if (![self.downloadedArray containsObject:sessionModel]) {
        [self.downloadedArray addObject:sessionModel];
    }
    
    
}
@end
