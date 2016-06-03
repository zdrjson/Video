//
//  ViewController.m
//  MergeVideo
//
//  Created by 张德荣 on 16/6/1.
//  Copyright © 2016年 zdrjson. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
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
        
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, finalDuration);
        
        //第一个视频的架构图
        AVMutableVideoCompositionLayerInstruction *firstLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        [firstLayerInstruction setTransform:CGAffineTransformIdentity atTime:kCMTimeZero];
        
        //第二个视频的架构图
        
        AVMutableVideoCompositionLayerInstruction *secondLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        
        [secondLayerInstruction setOpacityRampFromStartOpacity:0.7 toEndOpacity:0.2 timeRange:CMTimeRangeMake(kCMTimeZero, _firstAsset.duration)];
        
        //这个定你把数组顺序到一下，视频上下位置也跟着变了
//        mainInstruction.layerInstructions = [NSArray arrayWithObjects:secondLayerInstruction,firstLayerInstruction, nil];
        NSArray *layinstructions = @[firstLayerInstruction,secondLayerInstruction];
        mainInstruction.layerInstructions = layinstructions.reverseObjectEnumerator.allObjects;
        
        _mainComposition = [AVMutableVideoComposition videoComposition];
        _mainComposition.instructions = @[mainInstruction];
        _mainComposition.frameDuration = CMTimeMake(1, 30);
        _mainComposition.renderSize = CGSizeMake(320, 240);
        
        //导出路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = paths.firstObject;
        
        NSString *myPathsDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo.mov"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:myPathsDocs error:NULL];
        
        NSURL *url = [NSURL fileURLWithPath:myPathsDocs];
        
        NSLog(@"URL:- %@",url.description);
        
        //导出
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:_mixComposition presetName:AVAssetExportPresetLowQuality];
        
        exporter.outputURL = url;
        
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        
        exporter.shouldOptimizeForNetworkUse = YES;
        
        exporter.videoComposition = _mainComposition;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
           dispatch_async(dispatch_get_main_queue(), ^{
               [self exportDidFinish:exporter];
           });
        }];
        
        
        
    }
}
- (void)exportDidFinish:(AVAssetExportSession *)session{
    NSLog(@"exportDidFinish");
    NSLog(@"session = %ld",(long)session.status);
    
    if (session.status == AVAssetExportSessionStatusCompleted)
    {
        NSURL *outputURL = session.outputURL;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (error) {
                        
                        
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:@"存档失败"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        
                    }else {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                        message:@"存档成功"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        
                        [alert show];
                        
                        
                        
                    }
                    
                    
                });
            }];
        }
                              
                              
                              
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"存档失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

}
@end
