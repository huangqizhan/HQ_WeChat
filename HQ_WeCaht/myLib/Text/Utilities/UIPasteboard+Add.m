//
//  UIPasteboard+Add.m
//  YYStudyDemo
//
//  Created by hqz on 2018/8/14.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "UIPasteboard+Add.h"
#import "NSAttributedString+Add.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MyImage.h"

@interface UIPasteboard_Add : NSObject  @end

@implementation UIPasteboard_Add @end

NSString *const  TextPasteboardTypeAttributedString = @"TextPasteboardTypeAttributedString";
NSString *const  TextUTTypeWEBP = @"TextUTTypeWEBP";

@implementation UIPasteboard (Add)

- (NSData *)PNGData{
    return [self dataForPasteboardType:(id)kUTTypePNG];
}
- (void)setPNGData:(NSData *)PNGData{
    [self setData:PNGData forPasteboardType:(id)kUTTypePNG];
}
- (NSData *)JPEGData{
    return [self dataForPasteboardType:(id)kUTTypeJPEG];
}

- (void)setJPEGData:(NSData *)JPEGData{
    [self setData:JPEGData forPasteboardType:(id)kUTTypeJPEG];
}
- (NSData *)GIFData{
    return [self dataForPasteboardType:(id)kUTTypeGIF];
}
- (void)setGIFData:(NSData *)GIFData{
    [self setData:GIFData forPasteboardType:(id)kUTTypeGIF];
}
- (NSData *)WEBPData{
    return [self dataForPasteboardType:TextUTTypeWEBP];
}
- (void)setWEBPData:(NSData *)WEBPData{
    [self setData:WEBPData forPasteboardType:TextUTTypeWEBP];
}
- (NSData *)ImageData{
    return [self dataForPasteboardType:(id)kUTTypeImage];
}
- (void)setImageData:(NSData *)ImageData{
    [self setData:ImageData forPasteboardType:(id)kUTTypeImage];
}

- (void)setAttributedString:(NSAttributedString *)AttributedString{
    self.string = [AttributedString plainTextForRange:NSMakeRange(0, AttributedString.length)];
    NSData *data = [AttributedString archiveToData];
    if (data) {
        NSDictionary *item = @{TextPasteboardTypeAttributedString : data};
        [self addItems:@[item]];
    }
    ///图片
    [AttributedString enumerateAttribute:TextAttachmentAttributeName inRange:NSMakeRange(0, AttributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(TextAttachment *attachment, NSRange range, BOOL *stop) {
        
        // save image
        UIImage *simpleImage = nil;
        if ([attachment.content isKindOfClass:[UIImage class]]) {
            simpleImage = attachment.content;
        } else if ([attachment.content isKindOfClass:[UIImageView class]]) {
            simpleImage = ((UIImageView *)attachment.content).image;
        }
        if (simpleImage) {
            NSDictionary *item = @{@"com.apple.uikit.image" : simpleImage};
            [self addItems:@[item]];
        }
        // save animated image
        if ([attachment.content isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = attachment.content;
            Class aniImageClass = NSClassFromString(@"MyImage");
            UIImage *image = imageView.image;
            if (aniImageClass && [image isKindOfClass:aniImageClass]) {
                NSData *data = [image valueForKey:@"animatedImageData"];
                NSNumber *type = [image valueForKey:@"animatedImageType"];
                if (data) {
                    switch (type.unsignedIntegerValue) {
                        case YYImageTypeGIF: {
                            NSDictionary *item = @{(id)kUTTypeGIF : data};
                            [self addItems:@[item]];
                        } break;
                        case YYImageTypePNG: { // APNG
                            NSDictionary *item = @{(id)kUTTypePNG : data};
                            [self addItems:@[item]];
                        } break;
                        case YYImageTypeWebP: {
                            NSDictionary *item = @{(id)TextUTTypeWEBP : data};
                            [self addItems:@[item]];
                        } break;
                        default: break;
                    }
                }
            }
        }
    }];
    
}


- (NSAttributedString *)AttributedString {
    for (NSDictionary *items in self.items) {
        NSData *data = items[TextPasteboardTypeAttributedString];
        if (data) {
            return [NSAttributedString unarchiveFromData:data];
        }
    }
    return nil;
}



@end
