//
//  ViewController.m
//  MergeVideo
//
//  Created by 张德荣 on 16/6/1.
//  Copyright © 2016年 zdrjson. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVURLAsset *firstAsset;
@property (nonatomic, strong) AVURLAsset *secondAsset;
@property (nonatomic, strong) AVMutableVideoComposition *mainComposition;
@property (nonatomic, strong) AVMutableComposition *mixComposition;
@property (nonatomic, strong) UIImagePickerController *picker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)mergeVideo {
    
    
    if (self.videoURL) {
        NSLog(@"First Asset = %@",_firstAsset);
        self.firstAsset = [AVAsset assetWithURL:self.videoURL];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"rain" ofType:@"mp4"];
        NSLog(@"path is %@",path);
        _secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
        NSLog(@"second Asset = %@",_secondAsset);
    }
    if (_firstAsset && _secondAsset) {
    
        // 2.
        _mixComposition = [[AVMutableComposition alloc] init];
        
        // create first track
        AVMutableCompositionTrack *firstTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration) ofTrack:[self.firstAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
        
        // create second track
        AVMutableCompositionTrack *secondTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration) ofTrack:[self.secondAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
        
        //3.
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        CMTime finalDuration;
        CMTime result;
        //判断时长，其实这段没用，时长直接用自己拍的视频时长就行了
        NSLog(@"values =%f and %f",CMTimeGetSeconds(_firstAsset.duration),CMTimeGetSeconds(_secondAsset.duration));
        /**
         CMTime计算
         相加
         CMTime t3 = CMTimeAdd(t1, t2);
         想减
         CMTime t4 = CMTimeSubtract(t3, t1);

         
         */
        if (CMTimeGetSeconds(_firstAsset.duration) == CMTimeGetSeconds(_secondAsset.duration)) {
            finalDuration = _firstAsset.duration;
        } else if (CMTimeGetSeconds(_firstAsset.duration) > CMTimeGetSeconds(_secondAsset.duration)) {
            finalDuration = _firstAsset.duration;
            result = CMTimeSubtract(_firstAsset.duration, _secondAsset.duration);
        } else {
            finalDuration = _secondAsset.duration;
            result = CMTimeSubtract(_secondAsset.duration, _firstAsset.duration);
        }
        
    }
}

@end
