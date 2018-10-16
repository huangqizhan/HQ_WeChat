//
//  DownLoadBackImageCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/29.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "DownLoadBackImageCell.h"
#import "HQLocalImageManager.h"


@interface DownLoadBackImageCell ()

@property (nonatomic,strong) DownLoadContentImageView *contentImageView;

@end

@implementation DownLoadBackImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        _contentImageView = [[DownLoadContentImageView alloc] initWithFrame:CGRectMake(10, 10, App_Frame_Width-20, (App_Frame_Width-30)/3.0)];
        [self.contentView addSubview:_contentImageView];
    }
    return self;
}
- (void)setDateArray:(NSArray *)dateArray{
    _dateArray = dateArray;
    _contentImageView.dateArray = _dateArray;
}
- (void)setListModel:(ChatListModel *)listModel{
    _listModel = listModel;
    _contentImageView.listModel = _listModel;
}
- (void)setChatDetailCallBack:(void (^)(NSString *))chatDetailCallBack{
    _chatDetailCallBack = chatDetailCallBack;
    _contentImageView.chatDetailCallBack = _chatDetailCallBack;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@interface DownLoadContentImageView ()

@property (nonatomic,strong) DownLoadImageView *view1;
@property (nonatomic,strong) DownLoadImageView *view2;
@property (nonatomic,strong) DownLoadImageView *view3;

@end

@implementation DownLoadContentImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.view1];
        [self addSubview:self.view2];
        [self addSubview:self.view3];
    }
    return self;
}

- (void)setDateArray:(NSArray *)dateArray{
    _dateArray = dateArray;
    for (int i = 0; i<_dateArray.count; i++) {
        if (i == 0) {
            _view1.model = _dateArray[i];
        }else if (i == 1){
            _view2.model = _dateArray[i];
        }else if (i == 2){
            _view3.model = _dateArray[i];
        }
    }
}
- (void)setListModel:(ChatListModel *)listModel{
    _listModel = listModel;
    _view1.listModel = _view2.listModel = _view3.listModel = _listModel;
}
- (void)setChatDetailCallBack:(void (^)(NSString *))chatDetailCallBack{
    _chatDetailCallBack = chatDetailCallBack;
    _view1.chatDetailCallBack = _view2.chatDetailCallBack = _view3.chatDetailCallBack = _chatDetailCallBack;
}
- (DownLoadImageView *)view1{
    if (_view1 == nil) {
        _view1 = [[DownLoadImageView alloc] initWithFrame:CGRectMake(0, 0, (self.width-10)/3.0, self.height)];
        _view1.backgroundColor = [UIColor blackColor];
        _view1.layer.masksToBounds = YES;
        _view1.layer.cornerRadius = 5.0;
    }
    return _view1;
}
- (DownLoadImageView *)view2{
    if (_view2 == nil) {
        _view2 = [[DownLoadImageView alloc] initWithFrame:CGRectMake((self.width-10)/3.0+5, 0, (self.width-10)/3.0, self.height)];
        _view2.layer.masksToBounds = YES;
        _view2.backgroundColor = [UIColor blackColor];
        _view2.layer.cornerRadius = 5.0;
    }
    return _view2;
}
- (DownLoadImageView *)view3{
    if (_view3 == nil) {
        _view3 = [[DownLoadImageView alloc] initWithFrame:CGRectMake((self.width-10)*2/3.0+10, 0, (self.width-10)/3.0 , self.height)];
        _view3.backgroundColor = [UIColor blackColor];
        _view3.layer.masksToBounds = YES;
        _view3.layer.cornerRadius = 5.0;
    }
    return _view3;
}
@end


@interface DownLoadImageView ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong) DownLoadProcessView *processView;

@end

@implementation DownLoadImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
        [self addSubview:self.processView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDownloadAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)setModel:(DownloadFileModel *)model{
    _model = model;
//    [self sd_setImageWithURL:[NSURL URLWithString:_model.contentUrl] placeholderImage:HeadPlaceImage];
    _processView.downLoadModel = _model;
}
- (void)tapDownloadAction:(UITapGestureRecognizer *)tap{
    if (_model.isFinish) {
        self.listModel.chatBegImageFilePath = _model.downLoadName;
        if (_chatDetailCallBack) {
            _chatDetailCallBack(@"设置背景图片");
        }
    }else{
        WEAKSELF;
//        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_model.contentUrl] options:SDWebImageDownloaderProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            _model.downLoadProcess = receivedSize/expectedSize;
//            _processView.downLoadModel = _model;
//        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            if (image) {
//                NSString *fileName = [NSString stringWithFormat:@"ChatBegImageName_%lld",self.listModel.chatListId];
//                _model.downLoadProcess = 1;
//                _model.isFinish = YES;
//                _processView.downLoadModel = _model;
//                _model.downLoadName = fileName;
//                [_model saveToDBChatLisModelAsyThread:^(BOOL result) {
//                    NSLog(@"result = %d",result);
//                }];
//                [weakSelf saveImageToSandBoxWith:image andFileName:fileName];
//            }
//        }];
    }
}
- (void)saveImageToSandBoxWith:(UIImage *)imaage andFileName:(NSString *)fileName{
    self.listModel.chatBegImageFilePath = fileName;
    [[HQLocalImageManager shareImageManager] saveChatBegImage:imaage withFileName:fileName andScale:1.0 andComplite:^(BOOL result){
        if (_chatDetailCallBack) {
            if (result) {
                _chatDetailCallBack(@"设置背景图片");
            }else{
                NSLog(@"图片保存失败 请重试!");
            }
        }
    }];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (DownLoadProcessView *)processView{
    if (_processView == nil) {
        _processView = [[DownLoadProcessView alloc] initWithFrame:CGRectMake(0, self.height*5.0/6.0, self.width, self.height*1/6.0)];
        _processView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    return _processView;
}


@end



@interface DownLoadProcessView ()

@property (nonatomic,strong) CAShapeLayer *shapLayer;

@end

@implementation DownLoadProcessView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _shapLayer = [[CAShapeLayer alloc] init];
        _shapLayer.strokeColor = [UIColor greenColor].CGColor;
        _shapLayer.lineWidth = 30;
        [self.layer addSublayer:_shapLayer];
    }
    return self;
}

- (void)setDownLoadModel:(DownloadFileModel *)downLoadModel{
    _downLoadModel = downLoadModel;
//    [[UIColor greenColor] setFill];
    UIBezierPath *path  = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 15)];
    [path addLineToPoint:CGPointMake(self.width*_downLoadModel.downLoadProcess, 15)];
    _shapLayer.path = path.CGPath;
}


@end
