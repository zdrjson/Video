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
/** 切换分辨率传的字典(key:分部率名称，value:分辨率url) */
@property (nonatomic, strong) NSDictionary *resolutionDic;
/** 从xx秒开始播放视频跳转 */
@property (nonatomic, assign) NSInteger seekTime;
/**
 取消延时隐藏controlView的方法，在ViewController的delloc方法中调用
 用于解决：刚打开视频播放器，就关闭改页面，maskView的延时隐藏还未执行
 */
- (void)cancelAutoFadeOutControlBar;
@end
