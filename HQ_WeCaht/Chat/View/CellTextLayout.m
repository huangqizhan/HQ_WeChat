//
//  CellTextLayout.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/10/20.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "CellTextLayout.h"
#import "HQFaceTools.h"
#import "HQChatRegexHelper.h"
#import "HQImageIOHelper.h"
#import "HQFaceModel.h"

@implementation CellTextModifier
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
    CellTextModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount {
    if (lineCount == 0) return 0;
    CGFloat ascent = _font.pointSize * 0.86;
//    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + (lineCount - 1) * lineHeight;
}


@end


@implementation CellTextLayout

- (instancetype)initWith:(ChatMessageModel *)model{
    self = [super init];
    if (self) {
        [self _layoutText:model.contentString];
    }
    return self;
}
- (void)_layoutText:(NSString *)text{
    CellTextModifier *modifier = [CellTextModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:kChatCellTextFontSize];
    modifier.paddingTop = 0;
    modifier.paddingBottom = 2;
    TextContainer *container = [TextContainer new];
    container.size = CGSizeMake(CONTENTLABELWIDTH, CGFLOAT_MAX);
//    container.insets = UIEdgeInsetsMake(0, 0, 0, 0);
    container.linePositionModifier = modifier;
    _textLayout = [TextLayout layoutWithContainer:container text:[self _getAttText:text]];
    _textHeight = [modifier heightForLineCount:_textLayout.lines.count] +  0;
    if (_textLayout.textBoundingRect.size.width < CONTENTLABELWIDTH) {
        _textWidth = _textLayout.textBoundingRect.size.width;
    }else{
        _textWidth = CONTENTLABELWIDTH;
    }
    self.cellHeight = _textHeight + 40;
//    _textLayout = [TextLayout layoutWithContainerSize:CGSizeMake(App_Frame_Width- 40, 200) text:[self _getAttText]];
}
- (NSMutableAttributedString *)_getAttText:(NSString *)text{
    NSString *content = text?:@"";

    // 高亮状态的背景
    TextBorder *highlightBorder = [TextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-5, -5, -5, -5);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = kChatCellTextHighlightBackgroundColor;
   NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content];
    att.font = [UIFont systemFontOfSize:kChatCellTextFontSize];
    att.foreColor = kChatCellTextNormalColor;
    
    ///表情
    NSArray<NSTextCheckingResult *> *matches = [[HQChatRegexHelper regexEmoticon] matchesInString:att.string options:kNilOptions range:att.rangeOfAll];
     NSUInteger emoClipLength = 0;
    for (NSTextCheckingResult *res in matches) {
        if (res.range.location == NSNotFound || res
            .range.length <= 1) continue;
        NSRange range = res.range;
        range.location -= emoClipLength;
        if ([att attribut:TextHighlightAttributeName atIndex:range.location]) continue;
        if([att attribut:TextAttachmentAttributeName atIndex:range.location]) continue;
        NSString *imageName = [att.string substringWithRange:range];
        UIImage *image = [UIImage imageNamed:imageName];
        if (!image) continue;
        
        NSAttributedString *emText = [NSAttributedString h_attachmentStringWithEmojiImage:image fontSize:kChatCellTextFontSize];
        [att replaceCharactersInRange:range withAttributedString:emText];
        emoClipLength += range.length - 1;
    }
    ///链接
    NSArray *linkResults = [[HQChatRegexHelper regexHttpLink ] matchesInString:att.string options:kNilOptions range:att.rangeOfAll];
    for (NSTextCheckingResult *link in linkResults) {
        if (link.range.location == NSNotFound && link.range.length <= 1) continue;
        if ([att attribut:TextHighlightAttributeName atIndex:link.range.location] == nil) {
            [att h_setForeColor:kWBCellTextHighlightColor range:link.range];
            // 高亮状态
            TextHeightLight *highlight = [TextHeightLight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{@"link" : [att.string substringWithRange:NSMakeRange(link.range.location + 1, link.range.length - 1)]};
            [att h_setTextHighlight:highlight range:link.range];
        }
    }
    ///电话
    NSArray *phoneResults = [[HQChatRegexHelper regexPhoneNumber ] matchesInString:att.string options:kNilOptions range:att.rangeOfAll];
    for (NSTextCheckingResult *phone in phoneResults) {
        if (phone.range.location == NSNotFound && phone.range.length <= 1) continue;
        if ([att attribut:TextHighlightAttributeName atIndex:phone.range.location] == nil) {
            [att h_setForeColor:kWBCellTextHighlightColor range:phone.range];
            // 高亮状态
            TextHeightLight *highlight = [TextHeightLight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{@"link" : [att.string substringWithRange:NSMakeRange(phone.range.location + 1, phone.range.length - 1)]};
            [att h_setTextHighlight:highlight range:phone.range];
        }
    }
    return att;
}


@end

