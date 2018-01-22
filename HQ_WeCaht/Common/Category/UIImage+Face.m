//
//  UIImage+Face.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "UIImage+Face.h"

@implementation UIImage (Face)


+(NSArray *)faceImagesByFaceRecognitionWithImage:(UIImage *)image{
    
    CIContext * context = [CIContext contextWithOptions:nil];
    
    CIImage * cImage = [CIImage imageWithCGImage:image.CGImage];
    
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    
    NSArray * detectResult = [faceDetector featuresInImage:cImage];
    
    NSMutableArray * imagesArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i< detectResult.count; i++) {
        
        CIImage * faceImage = [cImage imageByCroppingToRect:[[detectResult objectAtIndex:i] bounds]];
        [imagesArr addObject:[UIImage imageWithCIImage:faceImage]];
    }
    
    return [NSArray arrayWithArray:imagesArr];
}

+(NSInteger)totalNumberOfFacesByFaceRecognitionWithImage:(UIImage *)image{
    CIContext * context = [CIContext contextWithOptions:nil];
    
    CIImage * cImage = [CIImage imageWithCGImage:image.CGImage];
    
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:param];
    
    
    NSArray * detectResult = [faceDetector featuresInImage:cImage];
    
    return detectResult.count;
}


+ (NSString *)detactErCodeWithImage:(UIImage *)image{
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          @"CIDetectorAccuracy", @"CIDetectorAccuracyHigh",nil];
    CIDetector *detector = nil;
    // 宏定义在pct文件中，这里用[[UIDevice currentDevice].systemVersion floatValue] >= 8.0替换
    detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                               context:nil
                                               options:options];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        return scannedResult;
    }else{
        return nil;
    }

}

@end
