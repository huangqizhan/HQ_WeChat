//
//  RunTimeViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "RunTimeViewController.h"
#import "Message.h"
#import "MessageForwarding.h"
#import <objc/runtime.h>
#import "RunTimeModel.h"


@interface RunTimeViewController ()

@property (nonatomic,copy) RunTimeModel *runModel;

@end

@implementation RunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RunTime";
    self.view.backgroundColor = [UIColor whiteColor];
    Message *message = [Message new];
    [message sendMessage:@"wechat"];
    size_t t =  class_getInstanceSize([Message class]);
    NSLog(@"t = %zuu",t);
//    [self test];
//     [self changeModelAction];
    [self addMethod];
}
///添加方法
- (void)addMethod{
    
    class_addMethod([_runModel class], @selector(addAction), (IMP)guessAnswer, "v@:");
    if ([_runModel respondsToSelector:@selector(addAction)]) {
        [_runModel performSelector:@selector(addAction)];
    }
}
void guessAnswer(id self,SEL _cmd){
    
    NSLog(@"He is from GuangTong %@",NSStringFromSelector(_cmd));
    
}
- (void)test{
    _runModel = [RunTimeModel new];
    _runModel.name = @"123";
    _runModel.address = @"hhh";
//    [self changePropertyValue];
   
    
    NSLog(@"_runModel firstSay = %@",[_runModel firstSay]);
    NSLog(@"_runModel secondSay = %@",[_runModel secondSay]);

}
///修改属性的值
- (void)changePropertyValue{
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList([_runModel class], &count);
    NSLog(@"count = %d",count);
    for (int i = 0; i<count; i++) {
        Ivar var = ivar[i];
        const char *name = ivar_getName(var);
        NSLog(@"name = %s",name);
        NSString *pName = [NSString  stringWithUTF8String:name];
        if ([pName isEqualToString:@"_name"]) {
            object_setIvar(_runModel, var, @"hua");
        }else if ([pName isEqualToString:@"_address"]){
            object_setIvar(_runModel, var, @"1234");
        }
    }
    NSLog(@"_runModel name = %@",_runModel.name);
    NSLog(@"_runModel = %@",_runModel.address);
}
///替换方法
- (void)changeModelAction{
    Method m1 = class_getInstanceMethod([_runModel class], @selector(firstSay));
    Method m2 = class_getInstanceMethod([_runModel class], @selector(secondSay));
    
    method_exchangeImplementations(m1, m2);
    NSString *secondName = [_runModel firstSay];
    NSLog(@"secondName = %@",secondName);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
