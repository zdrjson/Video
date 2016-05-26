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
/** ViewController总页面是否消失 */
@property (nonatomic, assign) BOOL viewDisappear;
/** 是否在cell上播放video */
@property (nonatomic, assign) BOOL isCellVideo;
/** 是否缩小视频在底部 */
@property (nonatomic, assign) BOOL isBottomVideo;
/** 是否切换分辨率 */
@property (nonatomic, assign) BOOL isChangeResolution;
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
/**
 带初始化调用次方法
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeThePlayer];
    }
    return self;
}
/**
 storyboard 、xib加载playerVie会调用次方法
 */
- (void)awakeFromNib{
    [self initializeThePlayer];
}

/**
 初始化player
 */
- (void)initializeThePlayer {
    //每次播放视频都解锁屏幕锁定
    [self unlockTheScreen];
}
- (void)dealloc{
    self.playerItem = nil;
    self.tableView = nil;
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 重置player
 */
- (void)resetPlayer{
    
    //改为为播放完
    self.playDidEnd = NO;
    self.playerItem = nil;
    self.didEnterBackground = NO;
    //视频跳转秒数置0
    self.seekTime = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //关闭定时器
    [self.timer invalidate];
    //暂停
    [self pause];
    //移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    //替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    //把player置为nil
    self.player = nil;
    if (self.isChangeResolution) {
        [self.controlView resetControlViewForResolution];
        self.isChangeResolution = NO;
    } else { //重置控制层View
        [self.controlView resetControlView];
    }
    // 非重播时，移除当前playerView
    if (!self.repeatToPlay) {
        [self removeFromSuperview];
    }
    //底部播放video改为NO
    self.isBottomVideo = NO;
    // cell上播放视频 && 不是重播时
    if (self.isCellVideo && !self.repeatToPlay) {
        //vicontroller中页面消失
        self.viewDisappear = YES;
        self.isCellVideo = NO;
        self.tableView = nil;
        self.indexPath = nil;
    }
}
- (void)resetControlViewForResolution
{
    
}
- (void)unlockTheScreen {
	
}
- (void)resetControlView
{
}
@end
