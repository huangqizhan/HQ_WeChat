//
//  TestPopViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2018/1/16.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import "TestPopViewController.h"
#import "UINavigationController+FullScreenGesture.h"


@interface TestPopViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}

@end

@implementation TestPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"pop";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"pop1";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"pop2";
    }else{
        cell.textLabel.text = @"pop3";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        Pop1Controller *pop1 = [Pop1Controller new];
        pop1.interactivePopMaxAllowedInitialDistanceToLeftEdge = 300;
        [self.navigationController pushViewController:pop1 animated:YES];
    }else if (indexPath.row == 1){
        Pop2Controller *pop2 = [Pop2Controller new];
        pop2.prefersNavigationBarHidden = YES;
        pop2.interactivePopMaxAllowedInitialDistanceToLeftEdge = 300;
        [self.navigationController pushViewController:pop2 animated:YES];
    }else if (indexPath.row == 2){
        Pop3Controller *pop3 = [Pop3Controller new];
        pop3.interactivePopMaxAllowedInitialDistanceToLeftEdge = 100;
        pop3.interactivePopDisabled  = YES;
        [self.navigationController pushViewController:pop3 animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end










@implementation  Pop1Controller


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"pop1";
    self.view.backgroundColor = [UIColor whiteColor];
    

}

@end


@implementation  Pop2Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"pop2";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    [but setTitle:@"push" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(buttonAciton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];

    
}

- (void)buttonAciton:(UIButton *)sender{
    Pop4Controller *pop4 = [Pop4Controller new];
    pop4.prefersNavigationBarHidden = NO;
    pop4.interactivePopMaxAllowedInitialDistanceToLeftEdge = 200;
    [self.navigationController pushViewController:pop4 animated:YES];
}


@end

@implementation  Pop3Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"pop3";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

@end

@implementation  Pop4Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"pop4";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}



@end
