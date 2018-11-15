//
//  HqChatMessageLabel.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/11.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HqChatMessageLabel.h"


@interface HqChatMessageLabel ()<UIGestureRecognizerDelegate>{
    NSMutableDictionary *_linkStyleAttributes;
    NSDictionary *_linkBackGourdColorDict;
    //标记点击link下标
    NSUInteger _index;
    //需要处理的字符串内容
    NSMutableAttributedString *_CurrentAttributeString;
    CGFloat _sapcingTop;
}

@property (nonatomic,strong)NSTextStorage *textStorage;
@property (nonatomic,strong)NSLayoutManager *layoutManager;
@property (nonatomic,strong)NSTextContainer *textContainer;
@property (nonatomic,strong)NSArray *webArray;
@property (nonatomic,strong)NSArray *phoneArray;
@property (nonatomic,strong)NSMutableArray *selectedClickArray;
//自定义文本链接数组
@property (nonatomic,strong)NSArray *userLinkArray;
//link  array
@property (nonatomic,strong)NSArray *linkArray;

/**
 *  可点击link的文本颜色 default blue
 */
@property (nonatomic, strong) UIColor *selectedLinkTextColor;

/**
 *  可点击link背景色  default  gray
 */
@property (nonatomic, strong) UIColor *selectedLinkBackGroudColor;


/**
 *  自定义link文字
 */
@property (nonatomic,strong)NSArray *linkTextArray;

/**
 *  link 类型 default ALL
 */
@property (nonatomic,assign)ChatLabelLinkStyle labelLinkStyle;

@end



@implementation HqChatMessageLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setConetntAttribute];
        self.linkTextArray = @[@"HQ_WeChar"];
        _tapSender = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        _tapSender.delegate = self;
        [self addGestureRecognizer:_tapSender];
    }
    return self;
}
- (void)setConetntAttribute{
    //textContainer
    _textContainer = [[NSTextContainer alloc] init];
    _textContainer.lineFragmentPadding = 0;
    _textContainer.lineBreakMode = self.lineBreakMode;
    _textContainer.maximumNumberOfLines = 0;
    _textContainer.size = self.frame.size;
    
    //layoutManager
    _layoutManager = [[NSLayoutManager alloc] init];
    [_layoutManager addTextContainer:_textContainer];
    [_textContainer setLayoutManager:_layoutManager];
//    _layoutManager.delegate = self;
    
    self.userInteractionEnabled = YES;
    _labelLinkStyle = ChatLabelLinkStyleALL;
    _selectedLinkTextColor = [UIColor blueColor];
    _sapcingTop = 0;
    _selectedLinkBackGroudColor = [UIColor colorWithRed:1.0 green:236/255.0 blue:166/255.0 alpha:1.0];
    _linkStyleAttributes = [NSMutableDictionary dictionary];
    [self updataTextWithCurrentText];
}

- (void)setAttrubuteString:(NSMutableAttributedString *)attrubuteString{
    _attrubuteString = attrubuteString;
    self.attributedText = _attrubuteString;
    if (_attrubuteString) {
        [self updataTextWithCurrentText];
    }
}
- (void)updataTextWithCurrentText{
    if (self.attributedText) {
        [self updataTextStorageWithAttributedString];
    }else if (self.text) {
        [self updataTextStorageWithAttributedString];
    }else {
        [self updataTextStorageWithAttributedString];
    }
    [self setNeedsDisplay];
}

- (void)updataTextStorageWithAttributedString{
    _CurrentAttributeString = [self.attrubuteString mutableCopy];
    //处理link
    if (_CurrentAttributeString.length != 0) {
        self.linkArray = [self regularExpressionManagerWithStr:_CurrentAttributeString.string];
        [self replaceAttributeLinkToOldAttributedString:_CurrentAttributeString withLinkArray:self.linkArray];
    }else {
        self.linkArray = nil;
    }
    if (_textStorage && _CurrentAttributeString) {
        [_textStorage setAttributedString:_CurrentAttributeString];
    }else {
        _textStorage = [[NSTextStorage alloc] initWithAttributedString:_CurrentAttributeString];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager setTextStorage:_textStorage];
    }
}
- (void)replaceAttributeLinkToOldAttributedString:(NSMutableAttributedString *)attributedString withLinkArray:(NSArray *)linkArray{
    for (int i = 0; i < linkArray.count; i++) {
        NSArray *rangeArray = [linkArray[i] allKeys];
        NSString *rangeString = [rangeArray firstObject];
        NSRange range = NSRangeFromString(rangeString);
        NSDictionary *attributes = @{NSForegroundColorAttributeName :_selectedLinkTextColor,NSStrokeWidthAttributeName:@(0)};
        [attributedString addAttributes:attributes range:range];
        if (_linkBackGourdColorDict && _index<=linkArray.count-1) {//点击需要背景色
            NSArray *CilckedRangeArray = [linkArray[_index] allKeys];
            NSString *CilckedRangeString = [CilckedRangeArray firstObject];
            NSRange CilckedRange = NSRangeFromString(CilckedRangeString);
            [attributedString addAttributes:_linkBackGourdColorDict range:CilckedRange];
        }
        NSDictionary *dict = @{NSUnderlineStyleAttributeName:@1};
        [attributedString addAttributes:dict range:range];
    }
}
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
    CGSize savedTextContainerSize = _textContainer.size;
    NSInteger savedTextContainerNumberOfLines = _textContainer.maximumNumberOfLines;
    
    _textContainer.size = bounds.size;
    _textContainer.maximumNumberOfLines = numberOfLines;
    
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    
    textBounds.origin = bounds.origin;
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height+2);
    
    _textContainer.size = savedTextContainerSize;
    _textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines;
    return textBounds;
}
- (void)drawTextInRect:(CGRect)rect{
    //重载原始图布局，需要调用super，自己绘制不需要调用super
    //    [super drawTextInRect:rect];
    //返回截取的范围
    rect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    //返回文本约束范围
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    CGPoint glyphsPosition = [self calcGlyphsPositionInView];
    
    [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:glyphsPosition];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:glyphsPosition];
}
- (CGPoint)calcGlyphsPositionInView{
    //返回绘制文字的实际范围
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    if (_sapcingTop!=0) {
        textBounds.origin.y = _sapcingTop;
    }else{
        textBounds.origin.y = self.bounds.origin.y;
    }
    return textBounds.origin;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([UIMenuController sharedMenuController].isMenuVisible) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        return NO;
    }
    return YES;
}
- (void)tapAction:(UITapGestureRecognizer *)tapSender{
    CGPoint touchLocation = [tapSender locationInView:self];
    [self calculateTouchesRange:touchLocation andCallBackResult:^(MessageLabelTapResult *resulr) {
        if (resulr) {
            _linkBackGourdColorDict = @{NSBackgroundColorAttributeName  :_selectedLinkBackGroudColor};
            [self updataTextWithCurrentText];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self upDataSeleteedBackgrround];
                if (_tapCallBackAction) {
                    if (resulr.linkStyle == ChatLabelLinkStyleIphoneNumber || resulr.linkStyle == ChatLabelLinkStyleWeb) {
                        _tapCallBackAction(resulr);
                    }
                }
            });
        }
    }];
}
- (void)upDataSeleteedBackgrround{
    _linkBackGourdColorDict = nil;
    [self updataTextWithCurrentText];
}
//计算点击是否在link range内
- (void )calculateTouchesRange:(CGPoint)location andCallBackResult:(void (^)(MessageLabelTapResult *resulr))callBack{
    //获取触摸点字符位置
    location.y -= _sapcingTop;
    NSUInteger touchedChar = [_layoutManager glyphIndexForPoint:location inTextContainer:_textContainer];
    for (int i = 0; i < self.linkArray.count; i++) {
        NSArray *rangeArray = [self.linkArray[i] allKeys];
        NSString *rangeString = [rangeArray firstObject];
        NSRange range = NSRangeFromString(rangeString);
        if (touchedChar>=range.location && touchedChar<=range.location+range.length) {
            NSArray *valueArray = [self.linkArray[i] allValues];
            _index = i;
            ChatLabelLinkStyle linkStyle = ChatLabelLinkStyleALL;
            MessageLabelTapResult *resut = [[MessageLabelTapResult alloc] init];
            if (i<_webArray.count&&i>-1) {//点击的是网址
                linkStyle = ChatLabelLinkStyleWeb;
            }else if (i<_phoneArray.count+_webArray.count&&i>-1) {//点击的是手机号码
                linkStyle = ChatLabelLinkStyleIphoneNumber;
            }else if (i>-1){//点击用户自定义文字
                linkStyle = ChatLabelLinkStyleUserText;
            }
            resut.linkStyle = linkStyle;
            resut.valueString = [valueArray firstObject];
            if (callBack) callBack(resut);
        }
    }
}
- (void)setLinkTextArray:(NSArray *)linkTextArray{
    _linkTextArray = linkTextArray;
    [self updataTextWithCurrentText];
}

- (NSMutableArray *)selectedClickArray{
    if (!_selectedClickArray) {
        _selectedClickArray = [NSMutableArray array];
    }
    return _selectedClickArray;
}
- (void)setSelectedLinkBackGroudColor:(UIColor *)selectedLinkBackGroudColor{
    _selectedLinkBackGroudColor = selectedLinkBackGroudColor;
    [self updataTextWithCurrentText];
}
- (void)setText:(NSString *)text{
    [super setText:text];
    if (!text) {
        text = @"";
    }
}
- (void)setSelectedLinkTextColor:(UIColor *)selectedLinkTextColor{
    _selectedLinkTextColor = selectedLinkTextColor;
    [self updataTextWithCurrentText];
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _textContainer.size = self.bounds.size;
}
- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    _textContainer.size = self.bounds.size;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _textContainer.size = self.bounds.size;
}

- (void)setLabelLinkStyle:(ChatLabelLinkStyle)labelLinkStyle{
    _labelLinkStyle = labelLinkStyle;
    [self updataTextWithCurrentText];
}

- (void)setSapcingTop:(NSInteger)sapcingTop{
    _sapcingTop = sapcingTop;
}
- (NSArray *)regularExpressionManagerWithStr:(NSString *)str{
    self.webArray = [[self class] matchStringWithWebLink:str];
    self.phoneArray = [[self class] matchStringWithPhoneLink:str];
    self.userLinkArray = [self matchStringWithLinkText:str];
    if (self.selectedClickArray.count) {
        [self.selectedClickArray removeAllObjects];
    }
    [self.selectedClickArray addObjectsFromArray:self.webArray];
    [self.selectedClickArray addObjectsFromArray:self.phoneArray];
    [self.selectedClickArray addObjectsFromArray:self.userLinkArray];
    if (_labelLinkStyle == ChatLabelLinkStyleWeb) {
        return self.webArray;
    }else if (_labelLinkStyle == ChatLabelLinkStyleIphoneNumber) {
        return self.phoneArray;
    }else if (_labelLinkStyle == ChatLabelLinkStyleUserText) {
        return self.userLinkArray;
    }else {
        return self.selectedClickArray;
    }
}

- (NSArray *)matchStringWithLinkText:(NSString *)oldString{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.linkTextArray.count; i++) {
        NSRange range = [oldString rangeOfString:_linkTextArray[i]];
        NSDictionary *dict = @{NSStringFromRange(range):_linkTextArray[i]};
        [array addObject:dict];
    }
    return array;
}
+ (NSArray *)matchStringWithPhoneLink:(NSString *)oldString{
    NSMutableArray *linkArr = [NSMutableArray array];
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"(\\(86\\))?(13[0-9]|17[0-9]|15[0-35-9]|18[01235-9])\\d{8}" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regExp matchesInString:oldString options:0 range:NSMakeRange(0, oldString.length)];
    for (NSTextCheckingResult *result in array) {
        NSString *string = [oldString substringWithRange:result.range];
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:string,NSStringFromRange(result.range), nil];
        [linkArr addObject:dic];
    }
    return linkArr;
}


+ (NSArray *)matchStringWithWebLink:(NSString *)oldString{
    NSMutableArray *linkArr = [NSMutableArray array];
    ///@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
    NSRegularExpression*regular=[[NSRegularExpression alloc]initWithPattern:@"((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray* array=[regular matchesInString:oldString options:0 range:NSMakeRange(0, [oldString length])];
    
    for( NSTextCheckingResult * result in array){
        
        NSString *string = [oldString substringWithRange:result.range];
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:string,NSStringFromRange(result.range), nil];
        
        [linkArr addObject:dic];
    }
    return linkArr;
    
}


@end



@implementation MessageLabelTapResult


@end
