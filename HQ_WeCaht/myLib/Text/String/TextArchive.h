//
//  TextArchive.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/19.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///此类主要是对 CGColoe CGImage  CTRubyAnnotation CTRunDelegate 的本地持久化
@interface TextArchive : NSKeyedArchiver <NSKeyedArchiverDelegate>

@end


@interface TextUnarchiver :NSKeyedUnarchiver <NSKeyedUnarchiverDelegate>


@end

NS_ASSUME_NONNULL_END
