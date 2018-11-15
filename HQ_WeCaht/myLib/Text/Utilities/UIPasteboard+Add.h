//
//  UIPasteboard+Add.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/14.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIPasteboard (Add)
@property (nullable, nonatomic, copy) NSData *PNGData;    ///< PNG file data
@property (nullable, nonatomic, copy) NSData *JPEGData;   ///< JPEG file data
@property (nullable, nonatomic, copy) NSData *GIFData;    ///< GIF file data
@property (nullable, nonatomic, copy) NSData *WEBPData;   ///< WebP file data
@property (nullable, nonatomic, copy) NSData *ImageData;  ///< image file data
@property (nullable, nonatomic, copy) NSAttributedString *AttributedString;

@end

NS_ASSUME_NONNULL_END
