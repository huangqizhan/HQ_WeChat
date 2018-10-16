//
//  UIApplication+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/29.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Add)

/// "Documents" folder in this app's sandbox.
@property (nonatomic, readonly) NSURL *documentsURL;
@property (nonatomic, readonly) NSString *documentsPath;

/// "Caches" folder in this app's sandbox.
@property (nonatomic, readonly) NSURL *cachesURL;
@property (nonatomic, readonly) NSString *cachesPath;

/// "Library" folder in this app's sandbox.
@property (nonatomic, readonly) NSURL *libraryURL;
@property (nonatomic, readonly) NSString *libraryPath;

/// Application's Bundle Name (show in SpringBoard).
@property (nullable, nonatomic, readonly) NSString *appBundleName;
/// Application's Bundle ID.  e.g. "com.ibireme.MyApp"
@property (nullable, nonatomic, readonly) NSString *appBundleID;
/// Application's Version.  e.g. "1.2.0"
@property (nullable, nonatomic, readonly) NSString *appVersion;
/// Application's Build number. e.g. "123"
@property (nullable, nonatomic, readonly) NSString *appBuildVersion;
/// Whether this app is pirated (not install from appstore).
@property (nonatomic, readonly) BOOL isPirated;
/// Whether this app is being debugged (debugger attached).
@property (nonatomic, readonly) BOOL isBeingDebugged;

/// Current thread real memory used in byte. (-1 when error occurs)
@property (nonatomic, readonly) int64_t memoryUsage;

/// Current thread CPU usage, 1.0 means 100%. (-1 when error occurs)
@property (nonatomic, readonly) float cpuUsage;


/**
 Increments the number of active network requests.
 If this number was zero before incrementing, this will start animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
- (void)incrementNetworkActivityCount;

/**
 Decrements the number of active network requests.
 If this number becomes zero after decrementing, this will stop animating the
 status bar network activity indicator.
 
 This method is thread safe.
 
 This method has no effect in App Extension.
 */
- (void)decrementNetworkActivityCount;


/// Returns YES in App Extension.
+ (BOOL)isAppExtension;

/// Same as sharedApplication, but returns nil in App Extension.
+ (nullable UIApplication *)sharedExtensionApplication;


@end

NS_ASSUME_NONNULL_END
