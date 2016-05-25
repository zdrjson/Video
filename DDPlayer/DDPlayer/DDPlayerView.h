//
//  DDPlayerView.h
//  DDPlayer
//
//  Created by 张德荣 on 16/5/25.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DDPlayerGoBackBlock)(void);
typedef NS_ENUM(NSInteger,DDPlayerLayerGravity) {
    DDPlayerGravityResize,
    DDPlayerGravityResizeAspect,
    DDPlayerGravityResizeAspectFill
};

@interface DDPlayerView : UIView
/** 视频URL */
@property (nonatomic, strong) NSURL *videoURL;
/** 视频URL的数组 */
@property (nonatomic, strong) NSArray *videURLArray;
/** 返回按钮Block */
@property (nonatomic, copy)DDPlayerGoBackBlock goBackBlock;
/** 设置playerLayer的填充模型 */
@property (nonatomic, assign) DDPlayerLayerGravity playerLayerGravity;
/** 是否有下载功能(默认是关闭) */
@property (nonatomic, assign) BOOL hasDownload;
@end
