//
//  CGutilies.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/25.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "CGutilies.h"
#import "UIView+Add.h"

CGContextRef CgcontextCreateARGBBitmapContext(CGSize size,BOOL opaque,CGFloat scale){
    size_t width = ceil(size.width*scale);
    size_t height = ceil(size.height*scale);
    if (width < 1 || height < 1) return NULL;
    /*
     如果没有 alhpa 分量，那就是 kCGImageAlphaNone。带有 skip
     的两个 kCGImageAlphaNoneSkipLast和kCGImageAlphaNoneSkipFirst即有 alpha
     分量，但是忽略该值，相当于透明度不起作用。kCGImageAlphaOnly只有 alpha
     值，没有颜色值。另外 4 个都表示带有 alpha
     通道。带有 Premultiplied，说明在图片解码压缩的时候，就将 alpha
     通道的值分别乘到了颜色分量上，我们知道 alpha 就会影响颜色的透明度，我们如果在压缩的时候就将这步做掉了，那么渲染的时候就不必再处理 alpha
     通道了，这样可以提高渲染速度。First 和 Last的区别就是 alpha
     分量是在像素存储的哪一边。例如一个像素点32位，表示4个分量，那么从左到右，如果是 ARGB，就表示 alpha
     分量在 first，RGBA 就表示 alpha
     分量在 last。
     */
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGImageAlphaInfo alpha = (!opaque ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, kCGBitmapByteOrderDefault | alpha);
    CGColorSpaceRelease(space);
    if (context) {
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, scale, -scale);
    }
    return context;
}

CGContextRef CGContextCreateGrayBitmapCgcontext(CGSize size,CGFloat scale){
    size_t width = ceil(size.width*scale);
    size_t height = ceil(size.height*scale);
    if (width < 1 || height < 1) return NULL;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
    CGImageAlphaInfo alphaInfo = kCGImageAlphaNone;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, kCGBitmapByteOrderDefault | alphaInfo);
    if (context) {
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, scale, -scale);
    }
    return context;
}
CGFloat ScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

CGSize ScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}




// return 0 when succeed
static int matrix_invert(__CLPK_integer N, double *matrix) {
    __CLPK_integer error = 0;
    __CLPK_integer pivot_tmp[6 * 6];
    __CLPK_integer *pivot = pivot_tmp;
    double workspace_tmp[6 * 6];
    double *workspace = workspace_tmp;
    bool need_free = false;
    
    if (N > 6) {
        need_free = true;
        pivot = malloc(N * N * sizeof(__CLPK_integer));
        if (!pivot) return -1;
        workspace = malloc(N * sizeof(double));
        if (!workspace) {
            free(pivot);
            return -1;
        }
    }
    
    dgetrf_(&N, &N, matrix, &N, pivot, &error);
    
    if (error == 0) {
        dgetri_(&N, matrix, &N, pivot, workspace, &N, &error);
    }
    
    if (need_free) {
        free(pivot);
        free(workspace);
    }
    return error;
}


