//
//  HQFaceModel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/28.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQFaceModel : NSObject

@property (nonatomic, copy) NSString *face_name;

@property (nonatomic, copy) NSString *face_id;

@property (nonatomic, copy) NSString *code;

///1 为系统自带的   2为自定义   3为大表情  4为GIF 5 addItem
@property (nonatomic,copy) NSString *type;

@property (nonatomic,copy) NSString *itemTitle;

@property (nonatomic,assign) BOOL isSeleted;

@end
