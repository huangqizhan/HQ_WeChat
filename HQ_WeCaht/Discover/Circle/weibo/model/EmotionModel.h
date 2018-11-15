//
//  EmotionModel.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WBEmoticonType) {
    WBEmoticonTypeImage = 0, ///< 图片表情
    WBEmoticonTypeEmoji = 1, ///< Emoji表情
};

@class WBEmoticonGroup;

@interface EmotionModel : NSObject
///< 例如 [吃惊]
@property (nonatomic, strong) NSString *chs;
///< 例如 [吃驚]
@property (nonatomic, strong) NSString *cht;
///< 例如 d_chijing.gif
@property (nonatomic, strong) NSString *gif;
///< 例如 d_chijing.png
@property (nonatomic, strong) NSString *png;
///< 例如 0x1f60d
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) WBEmoticonType type;
@property (nonatomic, weak) WBEmoticonGroup *group;

@end

@interface WBEmoticonGroup : NSObject
@property (nonatomic, strong) NSString *groupID; ///< 例如 com.sina.default
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSString *nameCN; ///< 例如 浪小花
@property (nonatomic, strong) NSString *nameEN;
@property (nonatomic, strong) NSString *nameTW;
@property (nonatomic, assign) NSInteger displayOnly;
@property (nonatomic, assign) NSInteger groupType;
@property (nonatomic, strong) NSArray<EmotionModel *> *emoticons;
@end



