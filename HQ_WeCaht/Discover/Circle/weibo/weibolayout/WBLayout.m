//
//  WBLayout.m
//  YYStudyDemo
//
//  Created by hqz on 2018/9/26.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "WBLayout.h"
#import "UIView+Add.h"
#import "WBHelper.h"
#import "TextUtilites.h"


/*
 将每行的 baseline 位置固定下来，不受不同字体的 ascent/descent 影响。
 
 注意，Heiti SC 中，    ascent + descent = font size，
 但是在 PingFang SC 中，ascent + descent > font size。
 所以这里统一用 Heiti SC (0.86 ascent, 0.14 descent) 作为顶部和底部标准，保证不同系统下的显示一致性。
 间距仍然用字体默认
 */
@implementation WBTextLinePositionModifier

- (instancetype)init {
    self = [super init];
    
    if (kiOS9Later) {
        _lineHeightMultiple = 1.34;   // for PingFang SC
    } else {
        _lineHeightMultiple = 1.3125; // for Heiti SC
    }
    
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(TextContainer *)container {
    //CGFloat ascent = _font.ascender;
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (TextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    WBTextLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount {
    if (lineCount == 0) return 0;
    //    CGFloat ascent = _font.ascender;
    //    CGFloat descent = -_font.descender;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;
}

@end

@interface WBImageAttachment : TextAttachment
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGSize size;
@end

@implementation WBImageAttachment{
    UIImageView *_imageView;
}
- (void)setContent:(id)content {
    _imageView = content;
}
- (id)content {
    /// UIImageView 只能在主线程访问
    if (pthread_main_np() == 0) return nil;
    if (_imageView) return _imageView;
    
    /// 第一次获取时 (应该是在文本渲染完成，需要添加附件视图时)，初始化图片视图，并下载图片
    /// 这里改成 YYAnimatedImageView 就能支持 GIF/APNG/WebP 动画了
    _imageView = [UIImageView new];
    _imageView.size = _size;
    [_imageView setImageWithURL:_imageURL placeholder:nil];
    return _imageView;
}
@end

@implementation WBLayout
- (instancetype)initWithStatus:(WBModel *)status style:(WBLayoutStyle)style {
    if (!status || !status.user) return nil;
    self = [super init];
    _wbModel = status;
    _style = style;
    [self layout];
    return self;
}

- (void)layout {
    [self _layout];
}
- (void)updateDate {
    [self _layoutSource];
}
- (void)_layout {
    
    _marginTop = kWBCellTopMargin;
    _titleHeight = 0;
    _profileHeight = 0;
    _textHeight = 0;
    _retweetHeight = 0;
    _retweetTextHeight = 0;
    _retweetPicHeight = 0;
    _retweetCardHeight = 0;
    _picHeight = 0;
    _cardHeight = 0;
    _toolbarHeight = kWBCellToolbarHeight;
    _marginBottom = kWBCellToolbarBottomMargin;
    
    
    // 文本排版，计算布局
    [self _layoutTitle];
    [self _layoutProfile];
    [self _layoutRetweet];
    if (_retweetHeight == 0) {
        [self _layoutPics];
        if (_picHeight == 0) {
            [self _layoutCard];
        }
    }
    [self _layoutText];
    [self _layoutTag];
    [self _layoutToolbar];
    
    // 计算高度
    _height = 0;
    _height += _marginTop;
    _height += _titleHeight;
    _height += _profileHeight;
    _height += _textHeight;
    if (_retweetHeight > 0) {
        _height += _retweetHeight;
    } else if (_picHeight > 0) {
        _height += _picHeight;
    } else if (_cardHeight > 0) {
        _height += _cardHeight;
    }
    if (_tagHeight > 0) {
        _height += _tagHeight;
    } else {
        if (_picHeight > 0 || _cardHeight > 0) {
            _height += kWBCellPadding;
        }
    }
    _height += _toolbarHeight;
    _height += _marginBottom;
}

- (void)_layoutTitle{
    _titleHeight = 0;
    _titleTextLayout = nil;
    WBStatusTitle *title = _wbModel.title;
    if (title.text.length == 0) return;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title.text];
    if (title.iconURL) {
        NSAttributedString *icon = [self _attachmentWithFontSize:kWBCellTitlebarFontSize imageURL:title.iconURL shrink:NO];
        if (icon) {
            [text insertAttributedString:icon atIndex:0];
        }
    }
    text.foreColor = kWBCellToolbarTitleColor;
    text.font = [UIFont systemFontOfSize:kWBCellTitlebarFontSize];
    TextContainer *container = [TextContainer containerWithSize:CGSizeMake(kScreenWidth - 100, kWBCellTitleHeight)];
    _titleTextLayout = [TextLayout layoutWithContainer:container text:text];
    _titleHeight = kWBCellTitleHeight;
}
- (void)_layoutProfile {
    [self _layoutName];
    [self _layoutSource];
    _profileHeight = kWBCellProfileHeight;
}

/// 名字
- (void)_layoutName {
    WBUser *user = _wbModel.user;
    NSString *nameStr = nil;
    if (user.remark.length) {
        nameStr = user.remark;
    } else if (user.screenName.length) {
        nameStr = user.screenName;
    } else {
        nameStr = user.name;
    }
    if (nameStr.length == 0) {
        _nameTextLayout = nil;
        return;
    }
    
    NSMutableAttributedString *nameText = [[NSMutableAttributedString alloc] initWithString:nameStr];
    
    // 蓝V
    if (user.userVerifyType == WBUserVerifyTypeOrganization) {
        UIImage *blueVImage = [WBHelper imageWithNamed:@"avatar_enterprise_vip"];
        NSAttributedString *blueVText = [self _attachmentWithFontSize:kWBCellNameFontSize image:blueVImage shrink:NO];
        [nameText h_appendString:@" "];
        [nameText appendAttributedString:blueVText];
    }
    
    // VIP
    if (user.mbrank > 0) {
        UIImage *yelllowVImage = [WBHelper imageWithNamed:[NSString stringWithFormat:@"common_icon_membership_level%d",user.mbrank]];
        if (!yelllowVImage) {
            yelllowVImage = [WBHelper imageWithNamed:@"common_icon_membership"];
        }
        NSAttributedString *vipText = [self _attachmentWithFontSize:kWBCellNameFontSize image:yelllowVImage shrink:NO];
        [nameText h_appendString:@" "];
        [nameText appendAttributedString:vipText];
    }
    
    nameText.font = [UIFont systemFontOfSize:kWBCellNameFontSize];
    nameText.foreColor = user.mbrank > 0 ? kWBCellNameOrangeColor : kWBCellNameNormalColor;
    nameText.lineBreakMode = NSLineBreakByCharWrapping;
    
    TextContainer *container = [TextContainer containerWithSize:CGSizeMake(kWBCellNameWidth, 9999)];
    container.maximumNumberOfRows = 1;
    _nameTextLayout = [TextLayout layoutWithContainer:container text:nameText];
}

/// 时间和来源
- (void)_layoutSource {
    NSMutableAttributedString *sourceText = [NSMutableAttributedString new];
    NSString *createTime = [WBHelper stringWithTimelineDate:_wbModel.createdAt];
    
    // 时间
    if (createTime.length) {
        NSMutableAttributedString *timeText = [[NSMutableAttributedString alloc] initWithString:createTime];
        [timeText h_appendString:@"  "];
        timeText.font = [UIFont systemFontOfSize:kWBCellSourceFontSize];
        timeText.foreColor = kWBCellTimeNormalColor;
        [sourceText appendAttributedString:timeText];
    }
    
    // 来自 XXX
    if (_wbModel.source.length) {
        // <a href="sinaweibo://customweibosource" rel="nofollow">iPhone 5siPhone 5s</a>
        static NSRegularExpression *hrefRegex, *textRegex;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=href=\").+(?=\" )" options:kNilOptions error:NULL];
            textRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=>).+(?=<)" options:kNilOptions error:NULL];
        });
        NSTextCheckingResult *hrefResult, *textResult;
        NSString *href = nil, *text = nil;
        hrefResult = [hrefRegex firstMatchInString:_wbModel.source options:kNilOptions range:NSMakeRange(0, _wbModel.source.length)];
        textResult = [textRegex firstMatchInString:_wbModel.source options:kNilOptions range:NSMakeRange(0, _wbModel.source.length)];
        if (hrefResult && textResult && hrefResult.range.location != NSNotFound && textResult.range.location != NSNotFound) {
            href = [_wbModel.source substringWithRange:hrefResult.range];
            text = [_wbModel.source substringWithRange:textResult.range];
        }
        if (href.length && text.length) {
            NSMutableAttributedString *from = [NSMutableAttributedString new];
            [from h_appendString:[NSString stringWithFormat:@"来自 %@", text]];
            from.font = [UIFont systemFontOfSize:kWBCellSourceFontSize];
            from.foreColor = kWBCellTimeNormalColor;
            if (_wbModel.sourceAllowClick > 0) {
                NSRange range = NSMakeRange(3, text.length);
                [from h_setForeColor:kWBCellTextHighlightColor range:range];
#warning ========
                TextBackedString *backed = [TextBackedString stringWithString:href];
                [from h_setTextBackedString:backed range:range];
                
                TextBorder *border = [TextBorder new];
                border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
                border.fillColor = kWBCellTextHighlightBackgroundColor;
                border.cornerRadius = 3;
                TextHeightLight *highlight = [TextHeightLight new];
                if (href) highlight.userInfo = @{kWBLinkHrefName : href};
                [highlight setBackgroundBorder:border];
                [from h_setTextHighlight:highlight range:range];
            }
            
            [sourceText appendAttributedString:from];
        }
    }
    
    if (sourceText.length == 0) {
        _sourceTextLayout = nil;
    } else {
        TextContainer *container = [TextContainer containerWithSize:CGSizeMake(kWBCellNameWidth, 9999)];
        container.maximumNumberOfRows = 1;
        _sourceTextLayout = [TextLayout layoutWithContainer:container text:sourceText];
    }
}

///转发
- (void)_layoutRetweet {
    _retweetHeight = 0;
    [self _layoutRetweetedText];
    [self _layoutRetweetPics];
    if (_retweetPicHeight == 0) {
        [self _layoutRetweetCard];
    }
    
    _retweetHeight = _retweetTextHeight;
    if (_retweetPicHeight > 0) {
        _retweetHeight += _retweetPicHeight;
        _retweetHeight += kWBCellPadding;
    } else if (_retweetCardHeight > 0) {
        _retweetHeight += _retweetCardHeight;
        _retweetHeight += kWBCellPadding;
    }
}
/// 文本
- (void)_layoutText {
    _textHeight = 0;
    _textLayout = nil;
    
    NSMutableAttributedString *text = [self _textWithStatus:_wbModel
                                                  isRetweet:NO
                                                   fontSize:kWBCellTextFontSize
                                                  textColor:kWBCellTextNormalColor];
    if (text.length == 0) return;
    
    WBTextLinePositionModifier *modifier = [WBTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kWBCellTextFontSize];
    modifier.paddingTop = kWBCellPaddingText;
    modifier.paddingBottom = kWBCellPaddingText;
    
    TextContainer *container = [TextContainer new];
    container.size = CGSizeMake(kWBCellContentWidth, HUGE);
    container.linePositionModifier = modifier;
    
    _textLayout = [TextLayout layoutWithContainer:container text:text];
    if (!_textLayout) return;
    
    _textHeight = [modifier heightForLineCount:_textLayout.rowCount];
}
- (void)_layoutPics {
    [self _layoutPicsWithStatus:_wbModel isRetweet:NO];
}
- (void)_layoutRetweetedText {
    _retweetHeight = 0;
    _retweetTextLayout = nil;
    NSMutableAttributedString *text = [self _textWithStatus:_wbModel.retweetedStatus
                                                  isRetweet:YES
                                                   fontSize:kWBCellTextFontRetweetSize
                                                  textColor:kWBCellTextSubTitleColor];
    if (text.length == 0) return;
    
    WBTextLinePositionModifier *modifier = [WBTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kWBCellTextFontRetweetSize];
    modifier.paddingTop = kWBCellPaddingText;
    modifier.paddingBottom = kWBCellPaddingText;
    
    TextContainer *container = [TextContainer new];
    container.size = CGSizeMake(kWBCellContentWidth, HUGE);
    container.linePositionModifier = modifier;
    
    _retweetTextLayout = [TextLayout layoutWithContainer:container text:text];
    if (!_retweetTextLayout) return;
    
    _retweetTextHeight = [modifier heightForLineCount:_retweetTextLayout.lines.count];
}

- (void)_layoutRetweetPics {
    [self _layoutPicsWithStatus:_wbModel.retweetedStatus isRetweet:YES];
}

- (void)_layoutPicsWithStatus:(WBModel *)status isRetweet:(BOOL)isRetweet {
    if (isRetweet) {
        _retweetPicSize = CGSizeZero;
        _retweetPicHeight = 0;
    } else {
        _picSize = CGSizeZero;
        _picHeight = 0;
    }
    if (status.pics.count == 0) return;
    
    CGSize picSize = CGSizeZero;
    CGFloat picHeight = 0;
    
    CGFloat len1_3 = (kWBCellContentWidth + kWBCellPaddingPic) / 3 - kWBCellPaddingPic;
    len1_3 = TextCGFloatPixelRound(len1_3);
    switch (status.pics.count) {
        case 1: {
            WBPicture *pic = _wbModel.pics.firstObject;
            WBPictureMetaModel *bmiddle = pic.bmiddle;
            if (pic.keepSize || bmiddle.width < 1 || bmiddle.height < 1) {
                CGFloat maxLen = kWBCellContentWidth / 2.0;
                maxLen = TextCGFloatPixelRound(maxLen);
                picSize = CGSizeMake(maxLen, maxLen);
                picHeight = maxLen;
            } else {
                CGFloat maxLen = len1_3 * 2 + kWBCellPaddingPic;
                if (bmiddle.width < bmiddle.height) {
                    picSize.width = (float)bmiddle.width / (float)bmiddle.height * maxLen;
                    picSize.height = maxLen;
                } else {
                    picSize.width = maxLen;
                    picSize.height = (float)bmiddle.height / (float)bmiddle.width * maxLen;
                }
                picSize = TextCGSizePixelRound(picSize);
                picHeight = picSize.height;
            }
        } break;
        case 2: case 3: {
            picSize = CGSizeMake(len1_3, len1_3);
            picHeight = len1_3;
        } break;
        case 4: case 5: case 6: {
            picSize = CGSizeMake(len1_3, len1_3);
            picHeight = len1_3 * 2 + kWBCellPaddingPic;
        } break;
        default: { // 7, 8, 9
            picSize = CGSizeMake(len1_3, len1_3);
            picHeight = len1_3 * 3 + kWBCellPaddingPic * 2;
        } break;
    }
    
    if (isRetweet) {
        _retweetPicSize = picSize;
        _retweetPicHeight = picHeight;
    } else {
        _picSize = picSize;
        _picHeight = picHeight;
    }
}
- (void)_layoutCard {
    [self _layoutCardWithStatus:_wbModel isRetweet:NO];
}
- (void)_layoutRetweetCard {
    [self _layoutCardWithStatus:_wbModel.retweetedStatus isRetweet:YES];
}
- (void)_layoutCardWithStatus:(WBModel *)status isRetweet:(BOOL)isRetweet {
    if (isRetweet) {
        _retweetCardType = WBStatusCardTypeNone;
        _retweetCardHeight = 0;
        _retweetCardTextLayout = nil;
        _retweetCardTextRect = CGRectZero;
    } else {
        _cardType = WBStatusCardTypeNone;
        _cardHeight = 0;
        _cardTextLayout = nil;
        _cardTextRect = CGRectZero;
    }
    WBPageInfo *pageInfo = status.pageInfo;
    if (!pageInfo) return;
    
    WBStatusCardType cardType = WBStatusCardTypeNone;
    CGFloat cardHeight = 0;
    TextLayout *cardTextLayout = nil;
    CGRect textRect = CGRectZero;
    
    if ((pageInfo.type == 11) && [pageInfo.objectType isEqualToString:@"video"]) {
        // 视频，一个大图片，上面播放按钮
        if (pageInfo.pagePic) {
            cardType = WBStatusCardTypeVideo;
            cardHeight = (2 * kWBCellContentWidth - kWBCellPaddingPic) / 3.0;
        }
    } else {
        BOOL hasImage = pageInfo.pagePic != nil;
        BOOL hasBadge = pageInfo.typeIcon != nil;
        WBButtonLink *button = pageInfo.buttons.firstObject;
        BOOL hasButtom = button.pic && button.name;
        
        /*
         badge: 25,25 左上角 (42)
         image: 70,70 方形
         100, 70 矩形
         btn:  60,70
         
         lineheight 20
         padding 10
         */
        textRect.size.height = 70;
        if (hasImage) {
            if (hasBadge) {
                textRect.origin.x = 100;
            } else {
                textRect.origin.x = 70;
            }
        } else {
            if (hasBadge) {
                textRect.origin.x = 42;
            }
        }
        textRect.origin.x += 10; //padding
        textRect.size.width = kWBCellContentWidth - textRect.origin.x;
        if (hasButtom) textRect.size.width -= 60;
        textRect.size.width -= 10; //padding
        
        NSMutableAttributedString *text = [NSMutableAttributedString new];
        if (pageInfo.pageTitle.length) {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:pageInfo.pageTitle];
            
            title.font = [UIFont systemFontOfSize:kWBCellCardTitleFontSize];
            title.foreColor = kWBCellNameNormalColor;
            [text appendAttributedString:title];
        }
        
        if (pageInfo.pageDesc.length) {
            if (text.length) [text h_appendString:@"\n"];
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:pageInfo.pageDesc];
            desc.font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            desc.foreColor = kWBCellNameNormalColor;
            [text appendAttributedString:desc];
        } else if (pageInfo.content2.length) {
            if (text.length) [text h_appendString:@"\n"];
            NSMutableAttributedString *content3 = [[NSMutableAttributedString alloc] initWithString:pageInfo.content2];
            content3.font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            content3.foreColor = kWBCellTextSubTitleColor;
            [text appendAttributedString:content3];
        } else if (pageInfo.content3.length) {
            if (text.length) [text h_appendString:@"\n"];
            NSMutableAttributedString *content3 = [[NSMutableAttributedString alloc] initWithString:pageInfo.content3];
            content3.font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            content3.foreColor = kWBCellTextSubTitleColor;
            [text appendAttributedString:content3];
        }
        
        if (pageInfo.tips.length) {
            if (text.length) [text h_appendString:@"\n"];
            NSMutableAttributedString *tips = [[NSMutableAttributedString alloc] initWithString:pageInfo.tips];
            tips.font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
            tips.foreColor = kWBCellTextSubTitleColor;
            [text appendAttributedString:tips];
        }
        
        if (text.length) {
            text.maxLineHeight = 20;
            text.minLineHeight = 20;
            text.lineBreakMode = NSLineBreakByTruncatingTail;
            
            TextContainer *container = [TextContainer containerWithSize:textRect.size];
            container.maximumNumberOfRows = 3;
            cardTextLayout = [TextLayout layoutWithContainer:container text:text];
        }
        
        if (cardTextLayout) {
            cardType = WBStatusCardTypeNormal;
            cardHeight = 70;
        }
    }
    
    if (isRetweet) {
        _retweetCardType = cardType;
        _retweetCardHeight = cardHeight;
        _retweetCardTextLayout = cardTextLayout;
        _retweetCardTextRect = textRect;
    } else {
        _cardType = cardType;
        _cardHeight = cardHeight;
        _cardTextLayout = cardTextLayout;
        _cardTextRect = textRect;
    }
    
}
- (void)_layoutTag {
    _tagType = WBStatusTagTypeNone;
    _tagHeight = 0;
    
    WBTag *tag = _wbModel.tagStruct.firstObject;
    if (tag.tagName.length == 0) return;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:tag.tagName];
    if (tag.tagType == 1) {
        _tagType = WBStatusTagTypePlace;
        _tagHeight = 40;
        text.foreColor = [UIColor colorWithWhite:0.217 alpha:1.000];
    } else {
        _tagType = WBStatusTagTypeNormal;
        _tagHeight = 32;
        if (tag.urlTypePic) {
            NSAttributedString *pic = [self _attachmentWithFontSize:kWBCellCardDescFontSize imageURL:tag.urlTypePic.absoluteString shrink:YES];
            [text insertAttributedString:pic atIndex:0];
        }
        // 高亮状态的背景
        TextBorder *highlightBorder = [TextBorder new];
        highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
        highlightBorder.cornerRadius = 2;
        highlightBorder.fillColor = kWBCellTextHighlightBackgroundColor;
        
        [text h_setForeColor:kWBCellTextHighlightColor range:text.rangeOfAll];
        
        // 高亮状态
        TextHeightLight *highlight = [TextHeightLight new];
        [highlight setBackgroundBorder:highlightBorder];
        // 数据信息，用于稍后用户点击
        highlight.userInfo = @{kWBLinkTagName : tag};
        [text h_setTextHighlight:highlight range:text.rangeOfAll];
    }
    text.font = [UIFont systemFontOfSize:kWBCellCardDescFontSize];
    
    TextContainer *container = [TextContainer containerWithSize:CGSizeMake(9999, 9999)];
    _tagTextLayout = [TextLayout layoutWithContainer:container text:text];
    if (!_tagTextLayout) {
        _tagType = WBStatusTagTypeNone;
        _tagHeight = 0;
    }
}
- (void)_layoutToolbar {
    // should be localized
    UIFont *font = [UIFont systemFontOfSize:kWBCellToolbarFontSize];
    TextContainer *container = [TextContainer containerWithSize:CGSizeMake(kScreenWidth, kWBCellToolbarHeight)];
    container.maximumNumberOfRows = 1;
    
    NSMutableAttributedString *repostText = [[NSMutableAttributedString alloc] initWithString:_wbModel.repostsCount <= 0 ? @"转发" : [WBHelper shortedNumberDesc:_wbModel.repostsCount]];
    repostText.font = font;
    repostText.foreColor = kWBCellToolbarTitleColor;
    _toolbarRepostTextLayout = [TextLayout layoutWithContainer:container text:repostText];
    _toolbarRepostTextWidth = TextCGFloatPixelRound(_toolbarRepostTextLayout.textBoundingRect.size.width);
    
    NSMutableAttributedString *commentText = [[NSMutableAttributedString alloc] initWithString:_wbModel.commentsCount <= 0 ? @"评论" : [WBHelper shortedNumberDesc:_wbModel.commentsCount]];
    commentText.font = font;
    commentText.foreColor = kWBCellToolbarTitleColor;
    _toolbarCommentTextLayout = [TextLayout layoutWithContainer:container text:commentText];
    _toolbarCommentTextWidth = TextCGFloatPixelRound(_toolbarCommentTextLayout.textBoundingRect.size.width);
    
    NSMutableAttributedString *likeText = [[NSMutableAttributedString alloc] initWithString:_wbModel.attitudesCount <= 0 ? @"赞" : [WBHelper shortedNumberDesc:_wbModel.attitudesCount]];
    likeText.font = font;
    likeText.foreColor = _wbModel.attitudesStatus ? kWBCellToolbarTitleHighlightColor : kWBCellToolbarTitleColor;
    _toolbarLikeTextLayout = [TextLayout layoutWithContainer:container text:likeText];
    _toolbarLikeTextWidth = TextCGFloatPixelRound(_toolbarLikeTextLayout.textBoundingRect.size.width);
}

- (NSMutableAttributedString *)_textWithStatus:(WBModel *)status
                                     isRetweet:(BOOL)isRetweet
                                      fontSize:(CGFloat)fontSize
                                     textColor:(UIColor *)textColor {
    if (!status) return nil;
    
    NSMutableString *string = status.text.mutableCopy;
    if (string.length == 0) return nil;
    if (isRetweet) {
        NSString *name = status.user.name;
        if (name.length == 0) {
            name = status.user.screenName;
        }
        if (name) {
            NSString *insert = [NSString stringWithFormat:@"@%@:",name];
            [string insertString:insert atIndex:0];
        }
    }
    // 字体
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    // 高亮状态的背景
    TextBorder *highlightBorder = [TextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = kWBCellTextHighlightBackgroundColor;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    text.font = font;
    text.foreColor = textColor;
    
    // 根据 urlStruct 中每个 URL.shortURL 来匹配文本，将其替换为图标+友好描述
    for (WBURL *wburl in status.urlStruct) {
        if (wburl.shortURL.length == 0) continue;
        if (wburl.urlTitle.length == 0) continue;
        NSString *urlTitle = wburl.urlTitle;
        if (urlTitle.length > 27) {
            urlTitle = [[urlTitle substringToIndex:27] stringByAppendingString:TextTruncationToken];
        }
        NSRange searchRange = NSMakeRange(0, text.string.length);
        do {
            NSRange range = [text.string rangeOfString:wburl.shortURL options:kNilOptions range:searchRange];
            if (range.location == NSNotFound) break;
            
            if (range.location + range.length == text.length) {
                if (status.pageInfo.pageID && wburl.pageID &&
                    [wburl.pageID isEqualToString:status.pageInfo.pageID]) {
                    if ((!isRetweet && !status.retweetedStatus) || isRetweet) {
                        if (status.pics.count == 0) {
                            [text replaceCharactersInRange:range withString:@""];
                            break; // cut the tail, show with card
                        }
                    }
                }
            }
            
            if ([text attribut:TextHighlightAttributeName atIndex:range.location] == nil) {
                
                // 替换的内容
                NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:urlTitle];
                if (wburl.urlTypePic.length) {
                    // 链接头部有个图片附件 (要从网络获取)
                    NSURL *picURL = [WBHelper defaultURLForImageURL:wburl.urlTypePic];
                    UIImage *image = [[WebImageCache sharedCache] getImageForKey:picURL.absoluteString];
                    NSAttributedString *pic = (image && !wburl.pics.count) ? [self _attachmentWithFontSize:fontSize image:image shrink:YES] : [self _attachmentWithFontSize:fontSize imageURL:wburl.urlTypePic shrink:YES];
                    [replace insertAttributedString:pic atIndex:0];
                }
                replace.font = font;
                replace.foreColor = kWBCellTextHighlightColor;
                
                // 高亮状态
                TextHeightLight *highlight = [TextHeightLight new];
                [highlight setBackgroundBorder:highlightBorder];
                // 数据信息，用于稍后用户点击
                highlight.userInfo = @{kWBLinkURLName : wburl};
                [replace h_setTextHighlight:highlight range:NSMakeRange(0, replace.length)];
                
                // 添加被替换的原始字符串，用于复制
                TextBackedString *backed = [TextBackedString stringWithString:[text.string substringWithRange:range]];
                [replace h_setTextBackedString:backed range:NSMakeRange(0, replace.length)];
                
                // 替换
                [text replaceCharactersInRange:range withAttributedString:replace];
                
                searchRange.location = searchRange.location + (replace.length ? replace.length : 1);
                if (searchRange.location + 1 >= text.length) break;
                searchRange.length = text.length - searchRange.location;
            } else {
                searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
                if (searchRange.location + 1>= text.length) break;
                searchRange.length = text.length - searchRange.location;
            }
        } while (1);
    }
    
    // 根据 topicStruct 中每个 Topic.topicTitle 来匹配文本，标记为话题
    for (WBTopic *topic in status.topicStruct) {
        if (topic.topicTitle.length == 0) continue;
        NSString *topicTitle = [NSString stringWithFormat:@"#%@#",topic.topicTitle];
        NSRange searchRange = NSMakeRange(0, text.string.length);
        do {
            NSRange range = [text.string rangeOfString:topicTitle options:kNilOptions range:searchRange];
            if (range.location == NSNotFound) break;
            
            if ([text attribut:TextHighlightAttributeName atIndex:range.location] == nil) {
                [text h_setForeColor:kWBCellTextHighlightColor range:range];
                
                // 高亮状态
                TextHeightLight *highlight = [TextHeightLight new];
                [highlight setBackgroundBorder:highlightBorder];
                // 数据信息，用于稍后用户点击
                highlight.userInfo = @{kWBLinkTopicName : topic};
                [text h_setTextHighlight:highlight range:range];
            }
            searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
            if (searchRange.location + 1>= text.length) break;
            searchRange.length = text.length - searchRange.location;
        } while (1);
    }
    
    // 匹配 @用户名
    NSArray *atResults = [[WBHelper regexAt] matchesInString:text.string options:kNilOptions range:text.rangeOfAll];
    for (NSTextCheckingResult *at in atResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        if ([text attribut:TextHighlightAttributeName atIndex:at.range.location] == nil) {
            [text h_setForeColor:kWBCellTextHighlightColor range:at.range];
            
            // 高亮状态
            TextHeightLight *highlight = [TextHeightLight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{kWBLinkAtName : [text.string substringWithRange:NSMakeRange(at.range.location + 1, at.range.length - 1)]};
            [text h_setTextHighlight:highlight range:at.range];
        }
    }
    
    // 匹配 [表情]
    NSArray<NSTextCheckingResult *> *emoticonResults = [[WBHelper regexEmoticon] matchesInString:text.string options:kNilOptions range:text.rangeOfAll];
    NSUInteger emoClipLength = 0;
    for (NSTextCheckingResult *emo in emoticonResults) {
        if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
        NSRange range = emo.range;
        range.location -= emoClipLength;
        if ([text attribut:TextHighlightAttributeName atIndex:range.location]) continue;
        if ([text attribut:TextAttachmentAttributeName atIndex:range.location]) continue;
        NSString *emoString = [text.string substringWithRange:range];
        NSString *imagePath = [WBHelper emoticonDic][emoString];
        UIImage *image = [WBHelper imageWithPath:imagePath];
        if (!image) continue;
        
        NSAttributedString *emoText = [NSAttributedString h_attachmentStringWithEmojiImage:image fontSize:fontSize];
        [text replaceCharactersInRange:range withAttributedString:emoText];
        emoClipLength += range.length - 1;
    }
    
    return text;
}
- (NSAttributedString *)_attachmentWithFontSize:(CGFloat)fontSize image:(UIImage *)image shrink:(BOOL)shrink {
    
    //    CGFloat ascent = YYEmojiGetAscentWithFontSize(fontSize);
    //    CGFloat descent = YYEmojiGetDescentWithFontSize(fontSize);
    //    CGRect bounding = YYEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    
    // Heiti SC 字体。。
    CGFloat ascent = fontSize * 0.86;
    CGFloat descent = fontSize * 0.14;
    CGRect bounding = CGRectMake(0, -0.14 * fontSize, fontSize, fontSize);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), 0, descent + bounding.origin.y, 0);
    
    TextRunDelegate *delegate = [TextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width;
    
    TextAttachment *attachment = [TextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = contentInsets;
    attachment.content = image;
    
    if (shrink) {
        // 缩小~
        CGFloat scale = 1 / 10.0;
        contentInsets.top += fontSize * scale;
        contentInsets.bottom += fontSize * scale;
        contentInsets.left += fontSize * scale;
        contentInsets.right += fontSize * scale;
        contentInsets = TextUIEdgeInsetPixelFloor(contentInsets);
        attachment.contentInsets = contentInsets;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TextAttachmentToken];
    [atr h_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr h_setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}
- (NSAttributedString *)_attachmentWithFontSize:(CGFloat)fontSize imageURL:(NSString *)imageURL shrink:(BOOL)shrink {
    /*
     微博 URL 嵌入的图片，比临近的字体要小一圈。。
     这里模拟一下 Heiti SC 字体，然后把图片缩小一下。
     */
    CGFloat ascent = fontSize * 0.86;
    CGFloat descent = fontSize * 0.14;
    CGRect bounding = CGRectMake(0, -0.14 * fontSize, fontSize, fontSize);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), 0, descent + bounding.origin.y, 0);
    CGSize size = CGSizeMake(fontSize, fontSize);
    
    if (shrink) {
        // 缩小~
        CGFloat scale = 1 / 10.0;
        contentInsets.top += fontSize * scale;
        contentInsets.bottom += fontSize * scale;
        contentInsets.left += fontSize * scale;
        contentInsets.right += fontSize * scale;
        contentInsets = TextUIEdgeInsetPixelFloor(contentInsets);
        size = CGSizeMake(fontSize - fontSize * scale * 2, fontSize - fontSize * scale * 2);
        size = TextCGSizePixelRound(size);
    }
    
    TextRunDelegate *delegate = [TextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width;
    
    WBImageAttachment *attachment = [WBImageAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = contentInsets;
    attachment.size = size;
    attachment.imageURL = [WBHelper defaultURLForImageURL:imageURL];
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TextAttachmentToken];
    [atr h_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr h_setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}
- (WBTextLinePositionModifier *)_textlineModifier {
    static WBTextLinePositionModifier *mod;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mod = [WBTextLinePositionModifier new];
        mod.font = [UIFont fontWithName:@"Heiti SC" size:kWBCellTextFontSize];
        mod.paddingTop = 10;
        mod.paddingBottom = 10;
    });
    return mod;
}

@end