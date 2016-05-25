//
//  ViewController.m
//  QRCatcher
//
//  Created by 张德荣 on 16/5/24.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) UIView *borderView;
//AVFoundation
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self setupAVFoundation];
//    [self setupLabelBorder];
    [self setupRippleAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAVFoundation {
	//session
    self.session = [[AVCaptureSession alloc] init];
    //device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    //input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [self.session addInput:input];
    } else {
        NSLog(@"%@",error);
        return;
    }
    //output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //add preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.preview.layer addSublayer:self.previewLayer];
    
    //start
    [self.session startRunning];
}
- (void)setupLabelBorder
{
    self.borderView.layer.borderWidth = 1;
    self.borderView.layer.borderColor = [[UIColor colorWithRed:65/225.0 green:182/255.0 blue:251 alpha:1] CGColor];
    self.borderView.backgroundColor = [UIColor colorWithRed:23/255.0 green:133/255.0 blue:251/255.0 alpha:0.3];
    self.borderView.hidden = YES;
}

- (void)setupRippleAnimation {
    
   
    CGFloat width = 4;
    CGRect pathFrame = CGRectMake(0, 0, 4, 4);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:width/2];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.position = self.view.center;
    shapeLayer.bounds = path.bounds;
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor colorWithRed:1.00f green:0.71f blue:0.71f alpha:1.00f] CGColor];
    shapeLayer.fillColor = [UIColor colorWithRed:1.00f green:0.82f blue:0.82f alpha:1.00f].CGColor;
    shapeLayer.lineWidth = 0.05;
    [self.view.layer addSublayer:shapeLayer];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(60, 60, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation,alphaAnimation];
    animation.duration = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    [shapeLayer addAnimation:animation forKey:nil];
    UIImageView * imageView = [[UIImageView alloc] init];
//    UIView *imageView = [UIView new];
//    imageView.image.size = CGSizeMake(20, 20);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blueColor];
    imageView.frame = CGRectMake(0, 0, 80, 80);
    imageView.center = self.view.center;
//    imageView.layer.borderWidth = 15;
    imageView.layer.cornerRadius = 80/2;
//    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
  
    
//    imageView.layer.masksToBounds = YES;
    imageView.clipsToBounds = YES;
    imageView.tintColor = [UIColor whiteColor];
//    imageView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:imageView];
//    self.view.backgroundColor = [UIColor redColor];
    NSLog(@"%@",NSStringFromCGRect(shapeLayer.frame));
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataMachineReadableCodeObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            self.borderView.hidden = NO;
            
        }
    }
}
@end
