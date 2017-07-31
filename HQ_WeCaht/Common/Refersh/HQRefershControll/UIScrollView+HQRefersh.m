//
//  UIScrollView+HQRefersh.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "UIScrollView+HQRefersh.h"
#import "HQRefershBaseControll.h"




/////替换object 方法
@implementation NSObject (Refersh)

+ (void)exchangeInstanceMethd1:(SEL)methed1 methd2:(SEL)methed2{
    method_exchangeImplementations(class_getInstanceMethod(self, methed1), class_getInstanceMethod(self, methed2));
}

+ (void)exchangeClassMethed2:(SEL)methed1 methed2:(SEL)methed2{
    method_exchangeImplementations(class_getClassMethod(self, methed1), class_getClassMethod(self, methed2));
}
@end




/////header

static const char RefreshHeaderKey = '\0';

@implementation UIScrollView (HQRefersh)



- (void)setHeaderRefersh:(HQRefershBaseControll *)headerRefersh{
    if (headerRefersh != self.headerRefersh) {
        [self.headerRefersh removeFromSuperview];
        [self addSubview:headerRefersh];
        [self willChangeValueForKey:@"header"]; ///kvo
        objc_setAssociatedObject(self, &RefreshHeaderKey, headerRefersh, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"header"];  ///kvo
    }
}
- (HQRefershBaseControll *)headerRefersh{
    return  objc_getAssociatedObject(self, &RefreshHeaderKey);
}

/////回调

static const char RefreshReloadDataBlockKey = '\0';


- (void)setReloadDataBlock:(void (^)(NSInteger))reloadDataBlock{
    [self willChangeValueForKey:@"reloadDataBlock"];
    objc_setAssociatedObject(self, &RefreshReloadDataBlockKey, reloadDataBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"reloadDataBlock"];
}
- (void (^)(NSInteger))reloadDataBlock{
    return objc_getAssociatedObject(self, &RefreshReloadDataBlockKey);
}

- (void)executeReloadDataBlock{
    !self.reloadDataBlock ? : self.reloadDataBlock(self.totalDataCount);
}

- (NSInteger)totalDataCount{
    NSInteger totalDataCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalDataCount += [tableView numberOfRowsInSection:section];
        }
    }else if ([self isKindOfClass:[UICollectionView class]]){
        UICollectionView *collectionView = (UICollectionView *)self;
        for (NSInteger section = 0; collectionView.numberOfSections; section++) {
            totalDataCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalDataCount;
}





- (void)setInsetT:(CGFloat)insetT{
    UIEdgeInsets inset = self.contentInset;
    inset.top = insetT;
    self.contentInset = inset;
}

- (CGFloat)insetT{
    return self.contentInset.top;
}

- (void)setInsetB:(CGFloat)insetB{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = insetB;
    self.contentInset = inset;
}

- (CGFloat)insetB{
    return self.contentInset.bottom;
}

- (void)setInsetL:(CGFloat)insetL{
    UIEdgeInsets inset = self.contentInset;
    inset.left = insetL;
    self.contentInset = inset;
}

- (CGFloat)insetL{
    return self.contentInset.left;
}

- (void)setInsetR:(CGFloat)insetR{
    UIEdgeInsets inset = self.contentInset;
    inset.right = insetR;
    self.contentInset = inset;
}

- (CGFloat)insetR{
    return self.contentInset.right;
}

- (void)setOffsetX:(CGFloat)offsetX{
    CGPoint offset = self.contentOffset;
    offset.x = offsetX;
    self.contentOffset = offset;
}

- (CGFloat)offsetX{
    return self.contentOffset.x;
}

- (void)setOffsetY:(CGFloat)offsetY{
    CGPoint offset = self.contentOffset;
    offset.y = offsetY;
    self.contentOffset = offset;
}

- (CGFloat)offsetY{
    return self.contentOffset.y;
}

- (void)setContentW:(CGFloat)contentW{
    CGSize size = self.contentSize;
    size.width = contentW;
    self.contentSize = size;
}
- (CGFloat)contentW{
    return self.contentSize.width;
}
- (void)setContentH:(CGFloat)contentH{
    CGSize size = self.contentSize;
    size.height = contentH;
    self.contentSize = size;
}

- (CGFloat)contentH{
    return self.contentSize.height;
}


@end
