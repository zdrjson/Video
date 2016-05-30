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
@end

@implementation DDDownloadManager

@end
