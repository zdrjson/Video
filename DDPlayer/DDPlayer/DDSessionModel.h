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

@interface DDSessionModel : NSObject

@end
