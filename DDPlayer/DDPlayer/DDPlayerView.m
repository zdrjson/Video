//
//  DDPlayerView.m
//  DDPlayer
//
//  Created by 张德荣 on 16/5/25.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import "DDPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
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
/**
 设置Player相关参数
 */
- (void)configDDPlayer{
    //初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    
    //每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:,改方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    //初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //此处为默认视频填充模式
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    //添加playerLayer到self.layer
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    //初始化显示controlView为YES
    self.isMaskShowing = YES;
    // 延迟隐藏controlView
    [self autoFadeOutControlBar];
    
    //计时器
    [self createTimer];
    
    //添加手势
    [self createGesture];
    
    //获取系统音量
    [self configureVolume];
    
    // 本地文件不设置DDPlayerStateBuffering状态
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
        self.state = DDPlayerStatePlaying;
        self.isLocalVideo = YES;
//        self.controlView.hasDownload
    } else {
        self.state = DDPlayerStateBuffering;
        self.isLocalVideo = NO;
    }
    //开始播放
    [self play];
//    self.controlView
    
}
- (void)unlockTheScreen {
	
}
- (void)resetControlView
{
}

- (void)autoFadeOutControlBar {
	
}

- (void)createTimer {
	
}

- (void)createGesture {
	
}

- (void)configureVolume{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumViewSlider = nil;
    for (UIView *view in volumeView.subviews) {
        if ([[view.class description] isEqualToString:@"MPVolumeSlider"]) {
            _volumViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) {
        /** handle the error in setCategoryError */
    }
    
    //监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}
/**
 耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification *)notificaiton
{
    NSDictionary *interuptionDic = notificaiton.userInfo;
    NSInteger routeChangeReason = [[interuptionDic valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
            [self play];
        }
            case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }
        default:
            break;
    }
}
@end
