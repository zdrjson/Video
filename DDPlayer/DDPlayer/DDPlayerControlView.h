//
//  DDPlayerControlView.h
//  DDPlayer
//
//  Created by 张德荣 on 16/5/31.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPlayerControlView : UIView
/** 当前播放时长lable */
@property (nonatomic, strong) UILabel *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel *totalTimeLabel;


/** 重播按钮 */
@property (nonatomic, strong, readonly) UIButton                *repeatBtn;
/** 滑杆 */
@property (nonatomic, strong, readonly) UISlider *videoSlider;

@end
