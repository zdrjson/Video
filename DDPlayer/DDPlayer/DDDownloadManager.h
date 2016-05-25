//
//  DDDownloadManager.h
//  DDPlayer
//
//  Created by 张德荣 on 16/5/24.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@end
