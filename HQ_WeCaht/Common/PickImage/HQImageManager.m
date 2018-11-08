//
//  HQImageManager.m
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/16.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "HQImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HQAssetModel.h"
#import "UIImage+Resize.h"


@interface HQImageManager ()

//@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end


@implementation HQImageManager

static CGSize AssetGridThumbnailSize;
static CGFloat HQScreenWidth;
static CGFloat HQScreenScale;

+ (instancetype)manager{
    static HQImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.cachingImageManager = [[PHCachingImageManager alloc] init];
        manager.cachingImageManager.allowsCachingHighQualityImages = YES;
        HQScreenWidth = [UIScreen mainScreen].bounds.size.width;
        // 测试发现，如果scale  在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
        HQScreenScale = 2.0;
        if (HQScreenWidth > 700) {
            HQScreenScale = 1.5;
        }
    });
    return manager;
}
- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (HQScreenWidth - 2 * margin - 4) / columnNumber - margin;
    AssetGridThumbnailSize = CGSizeMake(itemWH * HQScreenScale, itemWH * HQScreenScale);
}
/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized {
    NSInteger status = [self authorizationStatus];
    if (status == 0) {
        /**
         * 当某些情况下AuthorizationStatus == AuthorizationStatusNotDetermined时，无法弹出系统首次使用的授权alertView，系统应用设置里亦没有相册的设置，此时将无法使用，故作以下操作，弹出系统首次使用的授权alertView
         */
        [self requestAuthorizationWhenNotDetermined];
    }
    return status == 3;
}
- (NSInteger)authorizationStatus {
    if (iOS8Later) {
        return [PHPhotoLibrary authorizationStatus];
    } else {
        return [ALAssetsLibrary authorizationStatus];
    }
    return NO;
}
//AuthorizationStatus == AuthorizationStatusNotDetermined 时询问授权弹出系统授权alertView
- (void)requestAuthorizationWhenNotDetermined {
    if (iOS8Later) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }];
        });
    }
}
/// Get相册 smart Album (专辑)
- (void)getCameraRoallAlbum:(BOOL)allPickingVodio allPickingImage:(BOOL)allPickImage complite:(void (^)(HQAlbumModel *))complite{
    __block HQAlbumModel *albumModel;
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!allPickingVodio) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",PHAssetMediaTypeImage];
        }
        if (!allPickImage) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",PHAssetMediaTypeVideo];
        }
        if (!self.sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if ([collection isKindOfClass:[PHCollectionList  class]]) {
                continue;
            }
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                albumModel = [self modelWithResult:fetchResult name:collection.localizedTitle];
                if (complite) {
                    complite(albumModel);
                }
            }
        }
    }
}
///获取所有的专辑
- (void)getAllAlbum:(BOOL)allPickingVodio allPickingImage:(BOOL)allPickImage complite:(void (^)(NSArray<HQAlbumModel *> *))complite{
    NSMutableArray *albumArr = [NSMutableArray array];
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (allPickingVodio) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",PHAssetMediaTypeVideo];
        }
        if (allPickImage) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",PHAssetMediaTypeImage];
        }
        if (!self.sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        // 我的照片流 1.6.10重新加入..
        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (fetchResult.count < 1) continue;
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
                if ([self isCameraRollAlbum:collection.localizedTitle]) {
                    [albumArr insertObject:[self  modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
                } else {
                    [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
                }
            }
        }
        if (complite && albumArr.count > 0){
            complite(albumArr);
        }
    }
}
///专辑下面的图片
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<HQAssetModel *> *models))completion{
    NSMutableArray *photoArr = [NSMutableArray array];
    PHFetchResult *fetchResult = (PHFetchResult *)result;
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HQAssetModel *assModel = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (assModel) {
            [photoArr addObject:assModel];
        }
    }];
    if (completion) {
        completion(photoArr);
    }
}

- (HQAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage{
    HQAssetModel *assetModel;
    HQAssetModelMediaType type = HQAssetModelMediaTypePhoto;
    PHAsset *phasset = (PHAsset *)asset;
    if (phasset.mediaType == PHAssetMediaTypeVideo ) {
        type = HQAssetModelMediaTypeVideo;
    }else if (phasset.mediaType == PHAssetMediaTypeAudio){
        type = HQAssetModelMediaTypeAudio;
    }else if (phasset.mediaType == PHAssetMediaTypeImage){
        if ([[phasset valueForKey:@"filename"] hasPrefix:@"GIF"]) {
            type = HQAssetModelMediaTypePhotoGif;
        }
    }
    if (!allowPickingImage && type == HQAssetModelMediaTypePhoto) {
        return nil;
    }
    if (!allowPickingImage && type == HQAssetModelMediaTypePhotoGif) {
        return  nil;
    }
    if (!allowPickingVideo && type == HQAssetModelMediaTypeVideo) {
        return nil;
    }
    //        if (self.hideWhenCanNotSelect) {
    //            return nil;
    //        }
    NSString *timeLength =  type == HQAssetModelMediaTypeVideo?[NSString stringWithFormat:@"%0.0f",phasset.duration] : @"";
    timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
    assetModel = [HQAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    assetModel.size = CGSizeMake(phasset.pixelWidth, phasset.pixelHeight);
    assetModel.burstIdentifier = phasset.localIdentifier;
    return assetModel;
}
///  Get asset at index 获得下标为index的单个照片
///  if index beyond bounds, return nil in callback 如果索引越界, 在回调中返回 nil
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(HQAssetModel *))completion{
    PHFetchResult *fetchResult = (PHFetchResult *)result;
    PHAsset *asset;
    @try {
        asset = fetchResult[index];
    } @catch (NSException *exception) {
        if (completion) {
            completion(nil);
        }
    }
    HQAssetModel *assetModel = [self assetModelWithAsset:fetchResult allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
    if (completion) {
        completion(assetModel);
    }

}

/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(HQAlbumModel *)model completion:(void (^)(UIImage *postImage))completion{
    id asset = [model.result lastObject];
    if (!self.sortAscendingByModificationDate) {
        asset = [model.result firstObject];
    }
    [[HQImageManager manager] getPhotoWithAsset:asset photoWidth:400 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded , id identifer) {
        if (completion) completion(photo);
    }];

}
/// Export video 导出视频
- (void)getVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSString *outputPath))completion{
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        // NSLog(@"Info:\n%@",info);
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        // NSLog(@"AVAsset URL: %@",myAsset.URL);
        [self startExportVideoWithVideoAsset:videoAsset completion:completion];
    }];
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSString *outputPath))completion {
    // Find compatible presets by video asset.
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    // Begin to compress video
    // Now we just compress to low resolution if it supports
    // If you need to upload to the server, but server does't support to upload by streaming,
    // You can compress the resolution to lower. Or you can support more higher resolution.
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSLog(@"video outputPath = %@",outputPath);
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // Optimize for network use.
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
        if (videoComposition.renderSize.width) {
            // 修正视频转向
            session.videoComposition = videoComposition;
        }
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown"); break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting"); break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting"); break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(outputPath);
                        }
                    });
                }  break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed"); break;
                default: break;
            }
        }];
    }
}

/// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        } else {
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        }
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}
/// 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}
/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion{
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        HQAssetModel *model = photos[i];
        
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (model.type != HQAssetModelMediaTypeVideo) dataLength += imageData.length;
            assetCount ++;
            if (assetCount >= photos.count) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }];
    }
}
- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}
/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset{
    if (iOS8Later) {
        return [assets containsObject:asset];
    } else {
        NSMutableArray *selectedAssetUrls = [NSMutableArray array];
        for (ALAsset *asset_item in assets) {
            [selectedAssetUrls addObject:[asset_item valueForProperty:ALAssetPropertyURLs]];
        }
        return [selectedAssetUrls containsObject:[asset valueForProperty:ALAssetPropertyURLs]];
    }
}
- (NSString *)getAssetIdentifier:(id)asset{
    if (iOS8Later) {
        PHAsset *phAsset = (PHAsset *)asset;
        return phAsset.localIdentifier;
    } else {
        ALAsset *alAsset = (ALAsset *)asset;
        NSURL *assetUrl = [alAsset valueForProperty:ALAssetPropertyAssetURL];
        return assetUrl.absoluteString;
    }
}
#pragma mark ----- GET photo

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion{
    CGFloat fullScreenWidth = HQScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGFloat fullScreenWidth = HQScreenWidth;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        fullScreenWidth = phAsset.pixelWidth;
    }else{
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded,id identifier))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGSize imageSize;
    PHAsset *phAsset = (PHAsset *)asset;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = photoWidth * HQScreenScale;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue],phAsset.localIdentifier);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
//            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (progressHandler) {
//                        progressHandler(progress, error, stop, info);
//                    }
//                });
//            };
//            options.networkAccessAllowed = YES;
//            options.resizeMode = PHImageRequestOptionsResizeModeFast;
//            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//                resultImage = [self scaleImage:resultImage toSize:imageSize];
//                if (resultImage) {
//                    resultImage = [self fixOrientation:resultImage];
//                    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue],phAsset.localIdentifier);
//                }
//            }];
        }
    }];
    return imageRequestID;
}

- (void)getImageWithIdentifer:(NSArray <NSString *> *)identifers andWidth:(CGFloat)width complite:(void (^)(UIImage *iamge))complition{
    if (identifers.count == 0) return;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",PHAssetMediaTypeImage];
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:identifers options:option];
    if (result.count) {
        CGSize imageSize;
        PHAsset *phAsset = [result objectAtIndex:0];
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = width * HQScreenScale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
        // 修复获取图片时出现的瞬间内存过高问题
        // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
         [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                result = [self fixOrientation:result];
                if (complition) complition(result);
            }
        }];
    }
}
- (void)getImagesWith:(NSArray <HQAssetModel *> *)asserts complition:(void (^)(NSArray <TempModle *> *))complition{
    if (asserts.count == 0) return;
    NSMutableArray *images = [NSMutableArray new];
    NSMutableArray *identifers = [NSMutableArray new];
    for (HQAssetModel *model in asserts) {
        [identifers addObject:model.burstIdentifier];
    }
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",PHAssetMediaTypeImage];
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:identifers options:option];
    [result enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TempModle *model = [TempModle new];
        CGSize originSize = CGSizeMake(obj.pixelWidth, obj.pixelHeight);
        CGSize imageSize = [self.class handleImage:originSize];
        model.size = imageSize;
        model.origalSize = originSize;
        model.localIdentifier = obj.localIdentifier;
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                model.image = result;
                result = [self fixOrientation:result];
                [images addObject:model];
            }
        }];
    }];
    if (complition)complition(images);
}
#pragma mark ------ 保存图片 ----
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *error))completion {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
     // 这里有坑... iOS8系统下这个方法保存图片会失败 原来是因为PHAssetResourceType是iOS9之后的...
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
}
////保存图片   返回图片信息
- (void)NewSavePhotoWithImage:(UIImage *)image completion:(void (^)(UIImage *photo,NSDictionary *info, NSString *identifier))completion faild:(void (^)(NSError *error))faild{
        NSMutableArray *imageIds = [NSMutableArray array];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //写入图片到相册
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            //记录本地标识，等待完成后取到相册中的图片对象
            [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"success = %d, error = %@", success, error);
            if (success){
                //成功后取相册中的图片对象 763208EC-3E27-4706-B80F-1CA687CF67A5/L0/001
                ///379E45DD-8E49-44FB-B76C-9FAEE4A5E36C
                __block PHAsset *imageAsset = nil;
                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    imageAsset = obj;
                    *stop = YES;
                }];
                if (imageAsset){
                    //加载图片数据
                    [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        if (completion) {
                            completion([UIImage imageCompartionRatio:[self fixOrientation:[UIImage imageWithData:imageData]]],info,imageAsset.localIdentifier);
                        }
                    }];
                }
            }
        }];
}
#pragma mark ------ 获取原图  ---

/// Get Original Photo / 获取原图
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion {
    [self getOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo,info);
        }
    }];
}
- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) completion(result,info,isDegraded);
        }
    }];

}
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) completion(imageData,info,isDegraded);
        }
    }];
}
#pragma private  mark  -------

- (ALAssetOrientation)orientationFromImage:(UIImage *)image {
    NSInteger orientation = image.imageOrientation;
    return orientation;
}
/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}
- (CGSize)photoSizeWithAsset:(id)asset {
    if (iOS8Later) {
        PHAsset *phAsset = (PHAsset *)asset;
        return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    } else {
        ALAsset *alAsset = (ALAsset *)asset;
        return alAsset.defaultRepresentation.dimensions;
    }
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}

- (HQAlbumModel *)modelWithResult:(id)result name:(NSString *)name{
    HQAlbumModel *model = [[HQAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        model.count = [group numberOfAssets];
    }
    return model;
}
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}


/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
    return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


// 缩放，临时的方法
+ (CGSize)handleImage:(CGSize)retSize{
    CGFloat scaleH = 0.22;
    CGFloat scaleW = 0.38;
    CGFloat height = 0;
    CGFloat width = 0;
    if (retSize.height / APP_Frame_Height + 0.16 > retSize.width / App_Frame_Width) {
        height = APP_Frame_Height * scaleH;
        width = retSize.width / retSize.height * height;
    } else {
        width = App_Frame_Width * scaleW;
        height = retSize.height / retSize.width * width;
    }
    return CGSizeMake(width, height);
}

@end
