//
//  TextParser.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/4.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "TextParser.h"
#import "TextAttribute.h"
#import "TextUtilites.h"
#import "NSAttributedString+Add.h"
#import "NSParagraphStyle+Add.h"

@implementation  TextMarkDownParser{
    UIFont *_font;
    NSMutableArray *_headerFonts;
    UIFont *_boldFont;
    UIFont *_italiFont;
    UIFont *_boldItaliFont;
    UIFont *_monospaceFont;
    TextBorder *_border;
    
    ////注释
    NSRegularExpression *_regexEscape;
    ///标题
    NSRegularExpression *_regexHeader;
    ///H1
    NSRegularExpression *_regexH1;
    ///H2
    NSRegularExpression *_regexH2;
    ///断线
    NSRegularExpression *_regexBreakLine;
    ///强调
    NSRegularExpression *_regexEmphasis;
    ///加粗
    NSRegularExpression *_regexStrong;
    ///加粗强调
    NSRegularExpression *_regexStrongEmphasis;
    ///下划线
    NSRegularExpression *_regexUnderLine;
    ///删除线
    NSRegularExpression *_regexStrikeThrpugh;
    
    NSRegularExpression *_regexInlineCode;
    ///超链接
    NSRegularExpression *_regexLink;
    ///链接参考
    NSRegularExpression *_regexLinkRefer;
    
    NSRegularExpression *_regexList;
    
    NSRegularExpression *_regexBlockQuote;
    
    NSRegularExpression *_regexCodeBlock;
    
    NSRegularExpression *_regexNotEmptyLine;
    
}
- (void)initRegex{
#define regexp(part,option)  [NSRegularExpression regularExpressionWithPattern:@part options:option error:NULL]
    _regexEscape = regexp("(\\\\\\\\|\\\\\\`|\\\\\\*|\\\\\\_|\\\\\\(|\\\\\\)|\\\\\\[|\\\\\\]|\\\\#|\\\\\\+|\\\\\\-|\\\\\\!)", 0);
    _regexHeader = regexp("^((\\#{1,6}[^#].*)|(\\#{6}.+))$", NSRegularExpressionAnchorsMatchLines);
    _regexH1 = regexp("^[^=\\n][^\\n]*\\n=+$", NSRegularExpressionAnchorsMatchLines);
    _regexH2 = regexp("^[^-\\n][^\\n]*\\n-+$", NSRegularExpressionAnchorsMatchLines);
    _regexBreakLine = regexp("^[ \\t]*([*-])[ \\t]*((\\1)[ \\t]*){2,}[ \\t]*$", NSRegularExpressionAnchorsMatchLines);
    _regexEmphasis = regexp("((?<!\\*)\\*(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*(?!\\*)|(?<!_)_(?=[^ \\t_])(.+?)(?<=[^ \\t_])_(?!_))", 0);
    _regexStrong = regexp("(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)", 0);
    _regexStrongEmphasis =  regexp("((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))", 0);
    _regexUnderLine = regexp("(?<!_)__(?=[^ \\t_])(.+?)(?<=[^ \\t_])\\__(?!_)", 0);
    _regexStrikeThrpugh = regexp("(?<!~)~~(?=[^ \\t~])(.+?)(?<=[^ \\t~])\\~~(?!~)", 0);
    _regexInlineCode = regexp("(?<!`)(`{1,3})([^`\n]+?)\\1(?!`)", 0);
    _regexLink = regexp("!?\\[([^\\[\\]]+)\\](\\(([^\\(\\)]+)\\)|\\[([^\\[\\]]+)\\])", 0);
    _regexLinkRefer = regexp("^[ \\t]*\\[[^\\[\\]]\\]:", NSRegularExpressionAnchorsMatchLines);
    _regexList = regexp("^[ \\t]*([*+-]|\\d+[.])[ \\t]+", NSRegularExpressionAnchorsMatchLines);
    _regexBlockQuote = regexp("^[ \\t]*>[ \\t>]*", NSRegularExpressionAnchorsMatchLines);
    _regexCodeBlock = regexp("(^\\s*$\\n)((( {4}|\\t).*(\\n|\\z))|(^\\s*$\\n))+", NSRegularExpressionAnchorsMatchLines);
    _regexNotEmptyLine = regexp("^[ \\t]*[^ \\t]+[ \\t]*$", NSRegularExpressionAnchorsMatchLines);
#undef regex
}


- (void)_updateFonts{
    _font = [UIFont systemFontOfSize:_fontSize];
    _headerFonts = [NSMutableArray new];
    for (int i = 0; i < 6; i++) {
        CGFloat size = _headerFontSize - (_headerFontSize - _fontSize) / 5.0 * i;
        [_headerFonts addObject:[UIFont systemFontOfSize:size]];
    }
    _boldFont = TextFontWithBoldItalic(_font);
    _italiFont = TextFontWithItalic(_font);
    _boldItaliFont = TextFontWithBoldItalic(_font);
    _monospaceFont = [UIFont fontWithName:@"Menlo" size:_fontSize]; // Since iOS 7
    if (!_monospaceFont) _monospaceFont = [UIFont fontWithName:@"Courier" size:_fontSize]; // Since iOS 3
}
- (void)setColorWithBrightTheme {
    _textColor = [UIColor blackColor];
    _controlTextColor = [UIColor colorWithWhite:0.749 alpha:1.000];
    _headerTextColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000];
    _inlineTextColor = [UIColor colorWithWhite:0.150 alpha:1.000];
    _codeTextColor = [UIColor colorWithWhite:0.150 alpha:1.000];
    _linkTextColor = [UIColor colorWithRed:0.000 green:0.478 blue:0.962 alpha:1.000];
    
    _border = [TextBorder new];
    _border.lineStyle = TextLineStyleSingle;
    _border.fillColor = [UIColor colorWithWhite:0.184 alpha:0.090];
    _border.strokeColor = [UIColor colorWithWhite:0.546 alpha:0.650];
    _border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
    _border.cornerRadius = 2;
    _border.strokeWidth = TextCGFloatFromPixel(1);
}
- (void)setColorWithDarkTheme {
    _textColor = [UIColor whiteColor];
    _controlTextColor = [UIColor colorWithWhite:0.604 alpha:1.000];
    _headerTextColor = [UIColor colorWithRed:0.558 green:1.000 blue:0.502 alpha:1.000];
    _inlineTextColor = [UIColor colorWithRed:1.000 green:0.862 blue:0.387 alpha:1.000];
    _codeTextColor = [UIColor colorWithWhite:0.906 alpha:1.000];
    _linkTextColor = [UIColor colorWithRed:0.000 green:0.646 blue:1.000 alpha:1.000];
    
    _border = [TextBorder new];
    _border.lineStyle = TextLineStyleSingle;
    _border.fillColor = [UIColor colorWithWhite:0.820 alpha:0.130];
    _border.strokeColor = [UIColor colorWithWhite:1.000 alpha:0.280];
    _border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
    _border.cornerRadius = 2;
    _border.strokeWidth = TextCGFloatFromPixel(1);
}
- (NSUInteger)lenghOfBeginWhiteInString:(NSString *)str withRange:(NSRange)range{
    for (NSUInteger i = 0; i < range.length; i++) {
        unichar c = [str characterAtIndex:i + range.location];
        if (c != ' ' && c != '\t' && c != '\n') return i;
    }
    return str.length;
}
- (NSUInteger)lenghOfEndWhiteInString:(NSString *)str withRange:(NSRange)range{
    for (NSInteger i = range.length - 1; i >= 0; i--) {
        unichar c = [str characterAtIndex:i + range.location];
        if (c != ' ' && c != '\t' && c != '\n') return range.length - i;
    }
    return str.length;
}
- (NSUInteger)lenghOfBeginChar:(unichar)c inString:(NSString *)str withRange:(NSRange)range{
    for (NSUInteger i = 0; i < range.length; i++) {
        if ([str characterAtIndex:i + range.location] != c) return i;
    }
    return str.length;
}

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)range {
    if (text.length == 0) return NO;
    [text h_removeAttributesInRange:NSMakeRange(0, text.length)];
    text.font = _font;
    text.foreColor = _textColor;
    
    NSMutableString *str = text.string.mutableCopy;
    [_regexEscape replaceMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) withTemplate:@"@@"];
    
    [_regexHeader enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSUInteger whiteLen = [self lenghOfBeginWhiteInString:str withRange:r];
        NSUInteger sharpLen = [self lenghOfBeginChar:'#' inString:str withRange:NSMakeRange(r.location + whiteLen, r.length - whiteLen)];
        if (sharpLen > 6) sharpLen = 6;
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, whiteLen + sharpLen)];
        [text h_setForeColor:self->_headerTextColor range:NSMakeRange(r.location + whiteLen + sharpLen, r.length - whiteLen - sharpLen)];
        [text h_setFont:self->_headerFonts[sharpLen - 1] range:result.range];
    }];
    
    [_regexH1 enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange linebreak = [str rangeOfString:@"\n" options:0 range:result.range locale:nil];
        if (linebreak.location != NSNotFound) {
            [text h_setForeColor:self->_headerTextColor range:NSMakeRange(r.location, linebreak.location - r.location)];
            [text h_setFont:self->_headerFonts[0] range:NSMakeRange(r.location, linebreak.location - r.location + 1)];
            [text h_setForeColor:self->_controlTextColor range:NSMakeRange(linebreak.location + linebreak.length, r.location + r.length - linebreak.location - linebreak.length)];
        }
    }];
    
    [_regexH2 enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange linebreak = [str rangeOfString:@"\n" options:0 range:result.range locale:nil];
        if (linebreak.location != NSNotFound) {
            [text h_setForeColor:self->_headerTextColor range:NSMakeRange(r.location, linebreak.location - r.location)];
            [text h_setFont:self->_headerFonts[1] range:NSMakeRange(r.location, linebreak.location - r.location + 1)];
            [text h_setForeColor:self->_controlTextColor range:NSMakeRange(linebreak.location + linebreak.length, r.location + r.length - linebreak.location - linebreak.length)];
        }
    }];
    
    [_regexBreakLine enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [text h_setForeColor:self->_controlTextColor range:result.range];
    }];
    
    [_regexEmphasis enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, 1)];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 1, 1)];
        [text h_setFont:self->_italiFont range:NSMakeRange(r.location + 1, r.length - 2)];
    }];
    
    [_regexStrong enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, 2)];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text h_setFont:self->_boldFont range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexStrongEmphasis enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, 3)];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 3, 3)];
        [text h_setFont:self->_boldItaliFont range:NSMakeRange(r.location + 3, r.length - 6)];
    }];
    
    [_regexUnderLine enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, 2)];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text h_setTextUnderLine:[TextDecoration decorationWithStyle:TextLineStyleSingle width:@1 color:nil] range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexStrikeThrpugh enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, 2)];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text h_setStrikeThrough:[TextDecoration decorationWithStyle:TextLineStyleSingle width:@1 color:nil] range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexInlineCode enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSUInteger len = [self lenghOfBeginChar:'`' inString:str withRange:r];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location, len)];
        [text h_setForeColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - len, len)];
        [text h_setForeColor:self->_inlineTextColor range:NSMakeRange(r.location + len, r.length - 2 * len)];
        [text h_setFont:self->_monospaceFont range:r];
        [text h_setTextBorder:self->_border.copy range:r];
    }];
    
    [_regexLink enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_linkTextColor range:r];
    }];
    
    [_regexLinkRefer enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:r];
    }];
    
    [_regexList enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:r];
    }];
    
    [_regexBlockQuote enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text h_setForeColor:self->_controlTextColor range:r];
    }];
    
    [_regexCodeBlock enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange firstLineRange = [self->_regexNotEmptyLine rangeOfFirstMatchInString:str options:kNilOptions range:r];
        NSUInteger lenStart = (firstLineRange.location != NSNotFound) ? firstLineRange.location - r.location : 0;
        NSUInteger lenEnd = [self lenghOfEndWhiteInString:str withRange:r];
        if (lenStart + lenEnd < r.length) {
            NSRange codeR = NSMakeRange(r.location + lenStart, r.length - lenStart - lenEnd);
            [text h_setForeColor:self->_codeTextColor range:codeR];
            [text h_setFont:self->_monospaceFont range:codeR];
            TextBorder *border = [TextBorder new];
            border.lineStyle = TextLineStyleSingle;
            border.fillColor = [UIColor colorWithWhite:0.184 alpha:0.090];
            border.strokeColor = [UIColor colorWithWhite:0.200 alpha:0.300];
            border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
            border.cornerRadius = 3;
            border.strokeWidth = TextCGFloatFromPixel(2);
            [text h_setTextBlockBorder:self->_border.copy range:codeR];
        }
    }];
    return YES;
}

@end




#define LOCK(...)   dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@implementation  TextSimpleEmoticonParser{
    dispatch_semaphore_t _lock;
    NSDictionary *_mapper;
    NSRegularExpression *_regex;
    
}

- (instancetype)init{
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    return self;
}

- (NSDictionary <NSString *,__kindof UIImage *> *)emoticonMapper{
    LOCK(NSDictionary *mapper = _mapper);
    return mapper;
}
- (void)setEmoticonMapper:(NSDictionary<NSString *,__kindof UIImage *> *)emoticonMapper{
    LOCK(
         _mapper = emoticonMapper.copy;
         if (_mapper.count == 0){
             _regex = nil;
         }else{
             NSMutableString *pattern = @"(".mutableCopy;
             NSArray *allKeys = _mapper.allKeys;
             NSCharacterSet *character = [NSCharacterSet characterSetWithCharactersInString:@"$^?+*.,#|{}[]()\\"];
             for (NSUInteger i = 0,max = _mapper.count; i < max ; i++) {
                 NSMutableString *one = [allKeys[i] mutableCopy];
                 for (NSUInteger j = 0 , cmax = one.length; i < cmax; j++) {
                     UniChar ch = [one characterAtIndex:j];
                     if ([character characterIsMember:ch]) {
                         [pattern appendString:@"\\"];
                         j++;
                         cmax++;
                     }
                 }
                 [pattern appendString:one];
                 if (i != (max - 1)) {
                     [pattern appendString:@"|"];
                 }
             }
             [pattern appendString:@")"];
             _regex = [[NSRegularExpression alloc] initWithPattern:pattern options:kNilOptions error:NULL];
         }
    );
}

///修改 range 当替换 表情的时候
- (NSRange)_replaceTextInRange:(NSRange)range withLength:(NSUInteger)length selectedRange:(NSRange)selectedRange {
    // no change
    if (range.length == length) return selectedRange;
    // right
    if (range.location >= selectedRange.location + selectedRange.length) return selectedRange;
    // left
    if (selectedRange.location >= range.location + range.length) {
        selectedRange.location = selectedRange.location + length - range.length;
        return selectedRange;
    }
    // same
    if (NSEqualRanges(range, selectedRange)) {
        selectedRange.length = length;
        return selectedRange;
    }
    // one edge same
    if ((range.location == selectedRange.location && range.length < selectedRange.length) ||
        (range.location + range.length == selectedRange.location + selectedRange.length && range.length < selectedRange.length)) {
        selectedRange.length = selectedRange.length + length - range.length;
        return selectedRange;
    }
    selectedRange.location = range.location + length;
    selectedRange.length = 0;
    return selectedRange;
}

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)range{
    if (text.length == 0) return NO;
    NSDictionary *mapper;
    NSRegularExpression *regex;
    LOCK(mapper = _mapper; regex = _regex);
    if (mapper.count == 0 || regex == nil) return NO;
    NSArray *match = [regex matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
    if (match.count == 0)return NO;
    NSRange seletedRange = range ? *range : NSMakeRange(0, 0);
    NSUInteger curLength = 0;
    for (NSUInteger i = 0, max = match.count ; i < max ; i++) {
        NSTextCheckingResult *one = match[i];
        NSRange onerange = one.range;
        if (onerange.length == 0) continue;
        onerange.location -= curLength;
        NSString *subStr = [text.string substringWithRange:onerange];
        UIImage *emoticon = mapper[subStr];
        if (!emoticon) continue;
        CGFloat fontSize = 12; // CoreText default value
        CTFontRef font = (__bridge CTFontRef)([text fontAtIndex:onerange.location]);
        if (font) fontSize = CTFontGetSize(font);
        ////创建一个新的atts
        NSMutableAttributedString *atr = [NSAttributedString h_attachmentStringWithEmojiImage:emoticon fontSize:fontSize];
        [atr h_setTextBackedString:[TextBackedString  stringWithString:atr.string] range:NSMakeRange(0, atr.length)];
        [text replaceCharactersInRange:onerange withString:atr.string];
        [text h_removeDiscontinuousAttributesInRange:NSMakeRange(onerange.location, atr.length)];
        [text addAttributes:atr.attributes range:NSMakeRange(onerange.location, atr.length)];
        seletedRange = [self _replaceTextInRange:onerange withLength:atr.length selectedRange:seletedRange];
        curLength += onerange.length - 1;
    }
    if (range) *range = seletedRange;
    return YES;
}
@end
