//
//  HQDownLoadTempModel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQDownLoadFile.h"

@class HQDownLoadFile;

@interface HQDownLoadTempModel : NSObject <NSCoding>

@property (nonatomic,copy,nullable) NSString *urlStr;
@property (nonatomic,copy,nullable) NSString *fileName;
@property (nonatomic,copy,nullable) NSString *filePath;
@property (nonatomic,copy,nullable) NSString *trueName;
@property (nonatomic,copy,nullable) NSString *speed;
@property (nonatomic,assign) HQDownLoadFileStatus status;

////写入的字节数
@property (assign, nonatomic) long long totalBytesWritten;
////总字节数
@property (assign, nonatomic) long long totalBytesExpectedToWrite;

@property (nonatomic, copy,nullable) NSProgress *progress;

@property (strong, nonatomic,nullable) NSOutputStream *stream;

@property (nonatomic, assign) NSUInteger totalRead;
@property (nonatomic, strong,nullable) NSDate *date;



@property (nonatomic,copy,nullable) HQDownLoadSuccessBlock successBlock;
@property (nonatomic,copy,nullable) HQDownLoadFaildBlock faildBlock;
@property (nonatomic,copy,nullable) HQDownLoadProcessBlok processBlok;

+ (nonnull NSMutableDictionary * )allDownloadReceipts;

+ (void)saveModels:(NSMutableDictionary * _Nonnull )dic;

+ (void)UpdateModel:( NSMutableDictionary * _Nullable  )diction andComlite:( void (^ _Nullable )(BOOL  result))complite;

+ (void)DeleteModel:(HQDownLoadTempModel * _Nonnull )model andComplite:(void (^ _Nullable) (BOOL result))complite;

@end
