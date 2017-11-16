//
//  HQConstDefine.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#ifndef HQConstDefine_h
#define HQConstDefine_h

#define WEAK_SELF __weak typeof(self) weakSelf = self

#define APP_Frame_Height   [[UIScreen mainScreen] bounds].size.height

#define App_Frame_Width    [[UIScreen mainScreen] bounds].size.width
#define HeadPlaceImage [UIImage imageNamed:@"icon_album_picture_fail_big"]
#define ChatBegImageName @"chatBegImageName"
#define ChatMessagePeriodTime 120000   ///创建的时候扩大了1000倍

#define SCREENSCALE [UIScreen mainScreen].bounds.size.width/414

#define BUTTONBEGCOLOR [UIColor colorWithRed:75/255.0 green:162/255.0 blue:64/255.0 alpha:1]

#define HEIGHT_TABBAR       49      // 就是chatBox的高度

#define HEIGHT_SCREEN       [UIScreen mainScreen].bounds.size.height
#define WIDTH_SCREEN        [UIScreen mainScreen].bounds.size.width

#define     CHATBOX_BUTTON_WIDTH        37
#define     HEIGHT_TEXTVIEW             HEIGHT_TABBAR * 0.74
#define     MAX_TEXTVIEW_HEIGHT         104

#define videwViewH HEIGHT_SCREEN * 0.64 // 录制视频视图高度
#define videwViewX HEIGHT_SCREEN * 0.36 // 录制视频视图X


#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)




#define ALERT(msg)  [[[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil \
cancelButtonTitle:@"确定" otherButtonTitles:nil,nil] show]

#define App_Delegate ((AppDelegate*)[[UIApplication sharedApplication]delegate])

#define App_RootCtr  [UIApplication sharedApplication].keyWindow.rootViewController

#define WEAKSELF __weak typeof(self) weakSelf = self
#define STRONG_SELF if (!weakSelf) return; \
__strong typeof(weakSelf) strongSelf = weakSelf


//录音需要的最长时间
#define MAX_RECORD_TIME_ALLOWED 60

//录音需要的最短时间
#define MIN_RECORD_TIME_REQUIRED 1

#define XZColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define Global_mainBackgroundColor [UIColor colorWithRed:248/255.0 green:(248 / 255.0) blue:(248 / 255.0) alpha:1]

#define Global_tintColor [UIColor colorWithRed:0 green:(190 / 255.0) blue:(12 / 255.0) alpha:1]


#define HQFaceMenuViewHeight 36

#define IColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define XZRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define ICRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define BACKGROUNDCOLOR   XZRGB(0xf4f1f1)
#define SEARCHBACKGROUNDCOLOR  [UIColor colorWithRed:(110.0)/255.0 green:(110.0)/255.0 blue:(110.0)/255.0 alpha:0.4]
#define  CANCELBUTTONCOLOR [UIColor colorWithRed:(85.0)/255.0 green:(185.0)/255.0 blue:(50.0)/255.0 alpha:1]

#define BOTTOMBARCOLOR [UIColor colorWithRed:(34.0)/255.0 green:(35.0)/255.0 blue:(36.0)/255.0 alpha:1]

#define BackgroundColor_nearWhite [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1]

#define BackgroundColor_lightGray [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1]

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

#define CONTENTLABELWIDTH App_Frame_Width - 60 - 100




#define ICFont(FONTSIZE)  [UIFont systemFontOfSize:(FONTSIZE)]
#define ICBOLDFont(FONTSIZE)  [UIFont boldSystemFontOfSize:(FONTSIZE)]
#define ICSEARCHCANCELCOLOR    [UIColor orangeColor]
#define SEARCH_HEIGHT_COLOR   ICRGB(0x027996)

#define NE_BACKGROUND_COLOR ICRGB(0x027996)

#define kDiscvoerVideoPath @"Download/Video"  // video子路径
#define kChatVideoPath @"Chat/Video"  // video子路径
#define kVideoType @".mp4"        // video类型
#define kRecoderType @".wav"


#define kChatRecoderPath @"Chat/Recoder"
#define kRecodAmrType @".amr"




#define hqwechatDidReceiveNewMessaage @"hqwechatDidReceiveNewMessaage"






#endif /* HQConstDefine_h */
