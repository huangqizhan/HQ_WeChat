//
//  MyImage.h
//  YYStudyDemo
//
//  Created by hqz on 2018/7/4.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDeCode.h"
#import "SpriteSheetImage.h"
#import "AnimatedImageView.h"

/*
  MyImage 已经解码 在CPU  计算完之后 不用解码 直接给GPU渲染  不用解码
 
 */

/**
 A YYImage object is a high-level way to display animated image data.
 
 @discussion It is a fully compatible `UIImage` subclass. It extends the UIImage
 to support animated WebP, APNG and GIF format image data decoding. It also
 support NSCoding protocol to archive and unarchive multi-frame image data.
 
 If the image is created from multi-frame image data, and you want to play the
 animation, try replace UIImageView with `YYAnimatedImageView`.
 
 Sample Code:
 
 // animation@3x.webp
 YYImage *image = [YYImage imageNamed:@"animation.webp"];
 YYAnimatedImageView *imageView = [YYAnimatedImageView alloc] initWithImage:image];
 [view addSubView:imageView];
 
 */
@interface MyImage : UIImage <YYAnimatedImage>

+ (nullable MyImage *)imageNamed:(NSString *)name; // no cache!
+ (nullable MyImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable MyImage *)imageWithData:(NSData *)data;
+ (nullable MyImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

/**
 If the image is created from data or file, then the value indicates the data type.
 */
@property (nonatomic, readonly) YYImageType animatedImageType;

/**
 If the image is created from animated image data (multi-frame GIF/APNG/WebP),
 this property stores the original image data.
 */
@property (nullable, nonatomic, readonly) NSData *animatedImageData;

/**
 The total memory usage (in bytes) if all frame images was loaded into memory.
 The value is 0 if the image is not created from a multi-frame image data.
 */
@property (nonatomic, readonly) NSUInteger animatedImageMemorySize;

/**
 Preload all frame image to memory.
 
 @discussion Set this property to `YES` will block the calling thread to decode
 all animation frame image to memory, set to `NO` will release the preloaded frames.
 If the image is shared by lots of image views (such as emoticon), preload all
 frames will reduce the CPU cost.
 
 See `animatedImageMemorySize` for memory cost.
 */
@property (nonatomic) BOOL preloadAllAnimatedImageFrames;


@end
