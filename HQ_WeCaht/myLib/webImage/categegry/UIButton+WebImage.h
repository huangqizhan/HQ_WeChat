//
//  UIButton+WebImage.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/27.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebImageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (WebImage)

#pragma mark - image

/**
 Current image URL for the specified state.
 @return The image URL, or nil.
 */
- (nullable NSURL *)imageURLForState:(UIControlState)state;

/**
 Set the button's image with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder;

/**
 Set the button's image with a specified URL for the specified state.
 
 @param imageURL The image url (remote or local file path).
 @param state    The state that uses the specified image.
 @param options  The options to use when request the image.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
                options:(YYWebImageOptions)options;

/**
 Set the button's image with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder
                options:(YYWebImageOptions)options
             completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Set the button's image with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder
                options:(YYWebImageOptions)options
               progress:(nullable YYWebImageProgressBlock)progress
              transform:(nullable YYWebImageTransformBlock)transform
             completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Set the button's image with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param manager     The manager to create image request operation.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setImageWithURL:(nullable NSURL *)imageURL
               forState:(UIControlState)state
            placeholder:(nullable UIImage *)placeholder
                options:(YYWebImageOptions)options
                manager:(nullable WebImageManager *)manager
               progress:(nullable YYWebImageProgressBlock)progress
              transform:(nullable YYWebImageTransformBlock)transform
             completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Cancel the current image request for a specified state.
 @param state The state that uses the specified image.
 */
- (void)cancelImageRequestForState:(UIControlState)state;



#pragma mark - background image

/**
 Current backgroundImage URL for the specified state.
 @return The image URL, or nil.
 */
- (nullable NSURL *)backgroundImageURLForState:(UIControlState)state;

/**
 Set the button's backgroundImage with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder;

/**
 Set the button's backgroundImage with a specified URL for the specified state.
 
 @param imageURL The image url (remote or local file path).
 @param state    The state that uses the specified image.
 @param options  The options to use when request the image.
 */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                          options:(YYWebImageOptions)options;

/**
 Set the button's backgroundImage with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder
                          options:(YYWebImageOptions)options
                       completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Set the button's backgroundImage with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder
                          options:(YYWebImageOptions)options
                         progress:(nullable YYWebImageProgressBlock)progress
                        transform:(nullable YYWebImageTransformBlock)transform
                       completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Set the button's backgroundImage with a specified URL for the specified state.
 
 @param imageURL    The image url (remote or local file path).
 @param state       The state that uses the specified image.
 @param placeholder The image to be set initially, until the image request finishes.
 @param options     The options to use when request the image.
 @param manager     The manager to create image request operation.
 @param progress    The block invoked (on main thread) during image request.
 @param transform   The block invoked (on background thread) to do additional image process.
 @param completion  The block invoked (on main thread) when image request completed.
 */
- (void)setBackgroundImageWithURL:(nullable NSURL *)imageURL
                         forState:(UIControlState)state
                      placeholder:(nullable UIImage *)placeholder
                          options:(YYWebImageOptions)options
                          manager:(nullable WebImageManager *)manager
                         progress:(nullable YYWebImageProgressBlock)progress
                        transform:(nullable YYWebImageTransformBlock)transform
                       completion:(nullable YYWebImageCompletionBlock)completion;

/**
 Cancel the current backgroundImage request for a specified state.
 @param state The state that uses the specified image.
 */
- (void)cancelBackgroundImageRequestForState:(UIControlState)state;


@end

NS_ASSUME_NONNULL_END
