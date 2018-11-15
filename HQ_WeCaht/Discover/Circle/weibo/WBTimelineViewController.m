//
//  WBTimelineViewController.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/28.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "WBTimelineViewController.h"
#import "WBTableViewCell.h"
#import "WBModel.h"
#import "WBHeader.h"

@interface WBTimelineViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *layouts;
@end

@implementation WBTimelineViewController
- (instancetype)init {
    self = [super init];
    _tableView = [MyTableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _layouts = [NSMutableArray new];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector( setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.frame = self.view.bounds;
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    self.view.backgroundColor = kWBCellBackgroundColor;
    for (int i = 0; i <= 0; i++) {
        NSData *data = [NSData dataNamed:[NSString stringWithFormat:@"weibo_%d.json",i]];
        WBTimelineItem *item = [WBTimelineItem modelWithJSON:data];
//        for (int i = 0; i < item.statuses.count; i++) {
//            WBModel *status = item.statuses[i];
//            if (i == 0 || i == 1 || i == 2 || i == 3) {
//                if (i == 3) {
//                    status.text = nil;
//                }
//                WBLayout *layout = [[WBLayout alloc] initWithStatus:status style:WBLayoutStyleTimeline];
//                [_layouts addObject:layout];
//            }
//        }
        for (WBModel *status in item.statuses) {
//            if ([status.text containsString:@"iPhone 6s官方宣传视频曝光，你们城里人真会玩"]) {
//                WBLayout *layout = [[WBLayout alloc] initWithStatus:status style:WBLayoutStyleTimeline];
//                [_layouts addObject:layout];
//            }
            WBLayout *layout = [[WBLayout alloc] initWithStatus:status style:WBLayoutStyleTimeline];
            [_layouts addObject:layout];
        }
    }
   [_layouts addObjectsFromArray:_layouts];
    [_tableView reloadData];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"msg" style:UIBarButtonItemStylePlain target:self action:@selector(testAction:)]];
}
- (void)testAction:(UIButton *)sender{
    [_tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"cell";
    WBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[WBTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//        cell.delegate = self;
    }
    [cell setLayout:_layouts[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((WBLayout *)_layouts[indexPath.row]).height;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



@implementation MyTableView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Remove touch delay (since iOS 8)
    UIView *wrapView = self.subviews.firstObject;
    // UITableViewWrapperView
    if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
        for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
            // UIScrollViewDelayedTouchesBeganGestureRecognizer
            if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                gesture.enabled = NO;
                break;
            }
        }
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}


@end
