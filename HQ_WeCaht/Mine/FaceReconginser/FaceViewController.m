//
//  FaceViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "FaceViewController.h"

#define MainFrame [UIScreen mainScreen].bounds

@interface FaceViewController (){
    UIImageView * _inputImgView;
    UIButton    * _recognitionBtn;
    UILabel     * _recognitionFacesNumLabel;
    
    UIImage     * _inputImg;
}

@end

@implementation FaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"faces5" ofType:@".jpg"];
    _inputImg = [UIImage imageWithContentsOfFile:filePath];
    
    [self initViews];

}

-(void)initViews{
    
    _inputImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, _inputImg.size.width,_inputImg.size.height)];
    [_inputImgView setImage:_inputImg];
    [self.view addSubview:_inputImgView];
    
    
    _recognitionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recognitionBtn setTitle:@"识别" forState:UIControlStateNormal];
    [_recognitionBtn setBackgroundColor:[UIColor lightGrayColor]];
    [_recognitionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recognitionBtn setFrame:CGRectMake(20, MainFrame.size.height-100, MainFrame.size.width-40, 30)];
    [_recognitionBtn addTarget:self action:@selector(recognitionFaces) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recognitionBtn];
    
    
    
    _recognitionFacesNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MainFrame.size.height-150, MainFrame.size.width, 20)];
    _recognitionFacesNumLabel.text = @"人脸数：--";
    _recognitionFacesNumLabel.textColor = [UIColor blackColor];
    _recognitionFacesNumLabel.textAlignment = NSTextAlignmentCenter;
    _recognitionFacesNumLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_recognitionFacesNumLabel];
}

-(void)recognitionFaces{
    CIContext * context = [CIContext contextWithOptions:nil];
    
    UIImage * imageInput = [_inputImgView image];
    CIImage * image = [CIImage imageWithCGImage:imageInput.CGImage];
    
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    
    NSArray * detectResult = [faceDetector featuresInImage:image];
    
    
    UIView * resultView = [[UIView alloc] initWithFrame:_inputImgView.frame];
    [self.view addSubview:resultView];
    
    for (CIFaceFeature * faceFeature in detectResult) {
        UIView *faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        faceView.layer.borderColor = [UIColor redColor].CGColor;
        faceView.layer.borderWidth = 1;
        [resultView addSubview:faceView];
        
        
        if (faceFeature.hasLeftEyePosition) {
            UIView * leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            [leftEyeView setCenter:faceFeature.leftEyePosition];
            leftEyeView.layer.borderWidth = 1;
            leftEyeView.layer.borderColor = [UIColor redColor].CGColor;
            [resultView addSubview:leftEyeView];
        }
        
        
        if (faceFeature.hasRightEyePosition) {
            UIView * rightEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            [rightEyeView setCenter:faceFeature.rightEyePosition];
            rightEyeView.layer.borderWidth = 1;
            rightEyeView.layer.borderColor = [UIColor redColor].CGColor;
            [resultView addSubview:rightEyeView];
        }
        
        if (faceFeature.hasMouthPosition) {
            UIView * mouthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
            [mouthView setCenter:faceFeature.mouthPosition];
            mouthView.layer.borderWidth = 1;
            mouthView.layer.borderColor = [UIColor redColor].CGColor;
            [resultView addSubview:mouthView];
        }
        
        
    }
    [resultView setTransform:CGAffineTransformMakeScale(1, -1)];
    
    for (int i = 0; i< detectResult.count; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+105*i, 350, 100, 100)];
        CIImage * faceImage = [image imageByCroppingToRect:[[detectResult objectAtIndex:i] bounds]];
        [imageView setImage:[UIImage imageWithCIImage:faceImage]];
        [self.view addSubview:imageView];
        
    }
    
    if ([detectResult count] > 0) {
        _recognitionFacesNumLabel.text = [NSString stringWithFormat:@"人脸数：%lu",(unsigned long)detectResult.count];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
