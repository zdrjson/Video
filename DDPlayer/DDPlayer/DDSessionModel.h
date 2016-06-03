//
//  DDSessionModel.h
//  DDPlayer
//
//  Created by 张德荣 on 16/5/30.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, DDDownloadState) {
    //下载中
    DDSessionModelStart = 0,
    //下载暂停
    DDSessionModelSuspened,
    //下载完成
    DDSessionModelCompleted,
    //下载失败
    DDSessionModelFailed
};

typedef void(^DDDownloadProgressBlock)(CGFloat progress, NSString *speed, NSString *remainintTime, NSString *writtenSize, NSString *totalSize);
typedef void(^DDDownloadStateBlock) (DDDownloadState state);

@interface DDSessionModel : NSObject <NSCoding>
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 下载地址 */
@property (nonatomic, copy) NSString *url;
/** 开始下载时间 */
@property (nonatomic, strong) NSDate *starTime;
/** 文件名 */
@property (nonatomic, copy) NSString *fileName;
/** 文件大小 */
@property (nonatomic, copy) NSString *totalSize;

/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;

/** 下载进度 */
@property (atomic, copy) DDDownloadProgressBlock progressBlock;

/** 下载状态 */
@property (atomic, copy) DDDownloadStateBlock stateBlock;

- (float)calculateFieSizeInUnit:(unsigned long long)contentLength;

- (NSString *)calculateUnit:(unsigned long long)contentLength;

@end
