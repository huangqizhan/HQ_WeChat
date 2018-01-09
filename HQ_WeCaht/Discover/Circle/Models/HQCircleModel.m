//
//  HQCircleModel.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQCircleModel.h"
#import "UIColor+Extern.h"







NSString *const kWBLinkHrefName = @"href";
NSString *const kWBLinkURLName = @"url";
NSString *const kWBLinkTagName = @"tag";
NSString *const kWBLinkTopicName = @"topic";
NSString *const kWBLinkAtName = @"at";

@implementation HQCircleModel
- (instancetype)initWithStatus:(HQCircleWBStatus *)status style:(WBLayoutStyle)style{
    if (!status || !status.user) return nil;
    self = [super init];
    _status = status;
    _style = style;
    [self layout];
    return self;
}
- (void)layout{
//     [self _layout];
}
- (void)updateDate{
        [self _layoutSource];
}
//- (void)_layout {
//
//    _marginTop = kWBCellTopMargin;
//    _titleHeight = 0;
//    _profileHeight = 0;
//    _textHeight = 0;
//    _retweetHeight = 0;
//    _retweetTextHeight = 0;
//    _retweetPicHeight = 0;
//    _retweetCardHeight = 0;
//    _picHeight = 0;
//    _cardHeight = 0;
//    _toolbarHeight = kWBCellToolbarHeight;
//    _marginBottom = kWBCellToolbarBottomMargin;
//
//
//    // 文本排版，计算布局
//    [self _layoutTitle];
//    [self _layoutProfile];
//    [self _layoutRetweet];
//    if (_retweetHeight == 0) {
//        [self _layoutPics];
//        if (_picHeight == 0) {
//            [self _layoutCard];
//        }
//    }
//    [self _layoutText];
//    [self _layoutTag];
//    [self _layoutToolbar];
//
//    // 计算高度
//    _height = 0;
//    _height += _marginTop;
//    _height += _titleHeight;
//    _height += _profileHeight;
//    _height += _textHeight;
//    if (_retweetHeight > 0) {
//        _height += _retweetHeight;
//    } else if (_picHeight > 0) {
//        _height += _picHeight;
//    } else if (_cardHeight > 0) {
//        _height += _cardHeight;
//    }
//    if (_tagHeight > 0) {
//        _height += _tagHeight;
//    } else {
//        if (_picHeight > 0 || _cardHeight > 0) {
//            _height += kWBCellPadding;
//        }
//    }
//    _height += _toolbarHeight;
//    _height += _marginBottom;
//}
- (void)_layoutTitle {
//    _titleHeight = 0;
//    _titleTextLayout = nil;
//
//    HQCircleWBStatusTitle *title = _status.title;
//    if (title.text.length == 0) return;
//
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title.text];
//    if (title.iconURL) {
//        NSAttributedString *icon = [self _attachmentWithFontSize:kWBCellTitlebarFontSize imageURL:title.iconURL shrink:NO];
//        if (icon) {
//            [text insertAttributedString:icon atIndex:0];
//        }
//    }
//    text.color = kWBCellToolbarTitleColor;
//    text.font = [UIFont systemFontOfSize:kWBCellTitlebarFontSize];
//
//    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth - 100, kWBCellTitleHeight)];
//    _titleTextLayout = [YYTextLayout layoutWithContainer:container text:text];
//    _titleHeight = kWBCellTitleHeight;
}

/// 时间和来源
- (void)_layoutSource {
//    NSMutableAttributedString *sourceText = [NSMutableAttributedString new];
//    NSString *createTime = [WBStatusHelper stringWithTimelineDate:_status.createdAt];
//
//    // 时间
//    if (createTime.length) {
//        NSMutableAttributedString *timeText = [[NSMutableAttributedString alloc] initWithString:createTime];
//        [timeText appendString:@"  "];
//        timeText.font = [UIFont systemFontOfSize:kWBCellSourceFontSize];
//        timeText.color = kWBCellTimeNormalColor;
//        [sourceText appendAttributedString:timeText];
//    }
//
//    // 来自 XXX
//    if (_status.source.length) {
//        // <a href="sinaweibo://customweibosource" rel="nofollow">iPhone 5siPhone 5s</a>
//        static NSRegularExpression *hrefRegex, *textRegex;
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=href=\").+(?=\" )" options:kNilOptions error:NULL];
//            textRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=>).+(?=<)" options:kNilOptions error:NULL];
//        });
//        NSTextCheckingResult *hrefResult, *textResult;
//        NSString *href = nil, *text = nil;
//        hrefResult = [hrefRegex firstMatchInString:_status.source options:kNilOptions range:NSMakeRange(0, _status.source.length)];
//        textResult = [textRegex firstMatchInString:_status.source options:kNilOptions range:NSMakeRange(0, _status.source.length)];
//        if (hrefResult && textResult && hrefResult.range.location != NSNotFound && textResult.range.location != NSNotFound) {
//            href = [_status.source substringWithRange:hrefResult.range];
//            text = [_status.source substringWithRange:textResult.range];
//        }
//        if (href.length && text.length) {
//            NSMutableAttributedString *from = [NSMutableAttributedString new];
//            [from appendString:[NSString stringWithFormat:@"来自 %@", text]];
//            from.font = [UIFont systemFontOfSize:kWBCellSourceFontSize];
//            from.color = kWBCellTimeNormalColor;
//            if (_status.sourceAllowClick > 0) {
//                NSRange range = NSMakeRange(3, text.length);
//                [from setColor:kWBCellTextHighlightColor range:range];
//                YYTextBackedString *backed = [YYTextBackedString stringWithString:href];
//                [from setTextBackedString:backed range:range];
//
//                YYTextBorder *border = [YYTextBorder new];
//                border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
//                border.fillColor = kWBCellTextHighlightBackgroundColor;
//                border.cornerRadius = 3;
//                YYTextHighlight *highlight = [YYTextHighlight new];
//                if (href) highlight.userInfo = @{kWBLinkHrefName : href};
//                [highlight setBackgroundBorder:border];
//                [from setTextHighlight:highlight range:range];
//            }
//
//            [sourceText appendAttributedString:from];
//        }
//    }
//
//    if (sourceText.length == 0) {
//        _sourceTextLayout = nil;
//    } else {
//        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kWBCellNameWidth, 9999)];
//        container.maximumNumberOfRows = 1;
//        _sourceTextLayout = [YYTextLayout layoutWithContainer:container text:sourceText];
//    }
}
@end
