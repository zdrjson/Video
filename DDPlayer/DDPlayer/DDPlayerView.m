//
//  DDPlayerView.m
//  DDPlayer
//
//  Created by 张德荣 on 16/5/25.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import "DDPlayerView.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, PanDirection) {
    PanDirectionHorizontalMoved,   //横向移动
    PanDirectionVerticalMoved      //纵向移动
};

typedef NS_ENUM(NSUInteger, DDPlayerState) {
    DDPlayerStateFailed,     //播放失败
    DDPlayerStateBuffering,  //缓冲中
    DDPlayerStatePlaying,    //播放中
    DDPlayerStateStopped,    //停止播放
    DDPlayerStatePause       //暂停播放
};


@interface DDPlayerView ()
/** 播放属性 */
@property (nonatomic, strong) AVPlayer *player;
/** 播放属性 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/** 滑杠 */
@property (nonatomic, strong) UISlider *volumViewSlider;
/** 计时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 控制层View */
@property (nonatomic, strong) DDPlayerView *controlView;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat subTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection panDirection;
/** 播放器的几种状态 */
@property (nonatomic, assign) DDPlayerState state;
/** 是否为全屏 */
@property (nonatomic, assign) BOOL isFullScreen;
/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL isLocked;
/** 是否在调节音量 */
@property (nonatomic, assign) BOOL isVolume;
/** 是否显示controlView */
@property (nonatomic, assign) BOOL isMaskShowing;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL isLocalVideo;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat sliderLastValue;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL repeatToPlay;
/** 播放完了 */
@property (nonatomic, assign) BOOL playDidEnd;
/** 进入后台 */
@property (nonatomic, assign) BOOL didEnterBackground;

#pragma mark -UITableVieCell PlayerView
/** palyer加到tableView */
@property (nonatomic, strong) UITableView *tableView;
/** player所在cell的indexPath */
@property (nonatomic, strong) NSIndexPath *indexPath;
/** cell上imageView的tag */
@property (nonatomic, assign) NSInteger cellImageViewTag;
@property (nonatomic, assign) BOOL viewDisappear;

@end

@implementation DDPlayerView
#pragma mark - lift Cycle
+ (instancetype)sharePlayerView{
    static DDPlayerView *playerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerView = [[DDPlayerView alloc] init];
    });
    return playerView;
}
@end
