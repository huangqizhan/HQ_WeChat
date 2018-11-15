//
//  HQFaceTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/28.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQFaceTools.h"
#import "HQFaceModel.h"

#define kLLTextLinkColor [UIColor colorWithRed:0/255.0 green:104/255.0 blue:248/255.0 alpha:1]


static NSArray * _normalEmotions,*_custumEmotions,*_gifEmotions,*_moreFaceItems;

@implementation HQFaceTools
+ (NSArray *)getNormalEmotions{
    if (_normalEmotions) {
        return _normalEmotions;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CostomerEmoj.plist" ofType:nil];
    return  _normalEmotions = [HQFaceModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
}

+ (NSArray *)getCustomerEmotions{
    if (_custumEmotions) {
        return _custumEmotions;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SystemEmoj.plist" ofType:nil];
    return _custumEmotions = [HQFaceModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
}
////temp
+ (NSArray *)getGifEmotions{
    if (_gifEmotions) {
        return _gifEmotions;
    }
    NSMutableArray *gifArr = [NSMutableArray new];
    for (int i = 0; i<2; i++) {
        NSMutableArray *gifGroupArr = [NSMutableArray new];
        for (int j = i*8; j<8+i*8; j++) {
            HQFaceModel *model = [[HQFaceModel alloc] init];
            model.type = @"4";
            model.face_name = [NSString stringWithFormat:@"Tuzki_%d",(j+1)];
            [gifGroupArr addObject:model];
        }
        [gifArr addObject:gifGroupArr];
    }
    _gifEmotions = [NSArray arrayWithArray:gifArr];
    return _gifEmotions;
}

+ (NSArray *)getMoreFaceItems{
    if (_moreFaceItems) {
        return _moreFaceItems;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HQFaceMore.plist" ofType:nil];
    return _moreFaceItems = [HQFaceModel mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
}

/****/
+ (NSMutableAttributedString *)transferMessageString:(NSString *)message
                                                font:(UIFont *)font
                                          lineHeight:(CGFloat)lineHeight{
    message =  message?message:@"";
    NSMutableAttributedString *mutableAttribute = [[NSMutableAttributedString alloc] initWithString:message?message:@""];
//    NSString *remojStr = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";
//    NSError *error;
    NSRegularExpression *expression = [self regexEmoticon];
//    [NSRegularExpression regularExpressionWithPattern:remojStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (expression == nil) {
        return mutableAttribute;
    }
    NSMutableParagraphStyle *par = [[NSMutableParagraphStyle alloc] init];
    par.lineSpacing = 2.0;
    par.paragraphSpacing = 4.0;

    [mutableAttribute addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, message.length)];
    [mutableAttribute addAttribute:NSParagraphStyleAttributeName value:par range:NSMakeRange(0, message.length)];
    NSArray *resultArray = [expression matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    for (NSTextCheckingResult *match in resultArray) {
       NSString *subStr = [message substringWithRange:match.range];
        NSArray *faceArr = [HQFaceTools getNormalEmotions];
        for (NSArray *modelArray in faceArr) {
            for (HQFaceModel *model in modelArray) {
                if ([model.face_name isEqualToString:subStr]) {
                    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
                    attch.image = [UIImage imageNamed:model.face_name];
                    attch.bounds = CGRectMake(0, -4, lineHeight, lineHeight);
                    NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:attch];
                    NSMutableDictionary *imgDic = [[NSMutableDictionary alloc] initWithCapacity:2];
                    [imgDic setObject:imgStr forKey:@"image"];
                    [imgDic setObject:[NSValue valueWithRange:match.range] forKey:@"range"];
                    [mutableArray addObject:imgDic]; 
                }
            }
        }
    }
    for (int i = (int)mutableArray.count-1; i>=0; i--) {
        NSRange range;
        [mutableArray[i][@"range"] getValue:&range];
        [mutableAttribute replaceCharactersInRange:range withAttributedString:mutableArray[i][@"image"]];
    }
    return mutableAttribute;
}

+ (NSMutableAttributedString *)highlightDefaultDataTypes:(NSMutableAttributedString *)attributedString {
    
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink
                                                               error:&error];
    NSArray *matches = [detector matchesInString:attributedString.string
                                         options:kNilOptions
                                           range:NSMakeRange(0, [attributedString length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        BOOL shouldHighlight = NO;
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            if ([url.scheme isEqualToString: @"mailto"] ||
                [url.scheme isEqualToString:@"http"] ||
                [url.scheme isEqualToString:@"https"]) {
                shouldHighlight = YES;
            }
        }else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            shouldHighlight = YES;
        }
        
        if (shouldHighlight) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:kLLTextLinkColor range:matchRange];
        }
        
    }
    
    return attributedString;
}
///表情正则
+ (NSRegularExpression *)regexEmoticon {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]" options:kNilOptions error:NULL];
    });
    return regex;
}




@end
