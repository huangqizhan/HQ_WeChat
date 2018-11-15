//
//  MKAnnotationView+WebImage.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/27.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WebImageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKAnnotationView (WebImage)

/**
 Current image URL.
 
 @discussion Set a new value to this property will cancel the previous request
 operation and create a new request operation to fetch image. Set nil to clear
 the image and image URL.
 */
@property (nullable, nonatomic, strong) NSURL *imageURL;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder The image to be set initially, until the image request finishes.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL The image url (remote or local file path).
 @param options  The options to use when request the image.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL options:(YYWebImageOptions)options;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(YYWebImageOptions)options
             completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(YYWebImageOptions)options
               progress:(nullable YYWebImageProgressBlock)progress
              transform:(nullable YYWebImageTransformBlock)transform
             completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Set the view's `image` with a specified URL.
 
 @param imageURL    The image url (remote or local file path).
 @param placeholder he image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param manager     The manager to create image request operation.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
            placeholder:(nullable UIImage *)placeholder
                options:(YYWebImageOptions)options
                manager:(nullable WebImageManager *)manager
               progress:(nullable YYWebImageProgressBlock)progress
              transform:(nullable YYWebImageTransformBlock)transform
             completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Cancel the current image request.
 */
- (void)cancelCurrentImageRequest;

@end

NS_ASSUME_NONNULL_END
