//
//  HttpReDefine.h
//  KangLian
//
//  Created by GoodSrc on 2017/5/4.
//  Copyright © 2017年 Mask. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpReDefine : NSObject



extern NSString *const HOST;


extern NSString *const Prevent_HOST;

#define Approval_HOST HOST


// 文档

extern NSString *const DOC_HOST;


//应用top图片
// NSString *const Program_Top_Image_Url = @"/Service/Ppt/HomePptList";
extern NSString *const Program_Top_Image_Url;// HOST; //@"/Service/Ppt/HomePptList"
//登录
extern NSString *const Login_Url;// HOST;//@"/Service/User/Login"
//活动中心数据
extern NSString *const Activity_List_Url;// HOST@"/Service/ActivityCenter/List"
//视频中心数据
extern NSString *const Video_List_Url;// HOST@"/Service/VideoCenter/List"
//抗联公益数据
extern NSString *const Commonweal_List_Url;// HOST@"/Service/publicWelfare/List"

//活动中心详情
extern NSString *const Activity_Detail_Url;// HOST@"/Service/ActivityCenter/Detail?id="
//视频中心详情
extern NSString *const Video_Detail_Url;// HOST@"/Service/VideoCenter/Detail?id="
//抗联公益详情
extern NSString *const Commonweal_Detail_Url;// HOST@"/Service/publicWelfare/Detail?id="

//产品top图片
extern NSString *const Product_Top_Image_Url;// HOST@"/Service/Ppt/ProductPptList"
//杂草中心top图片
extern NSString *const Weed_Top_Image_Url;// HOST@"/Service/Ppt/WeedPptList"
//抗性反馈列表
extern NSString *const Resistance_List_Url;// HOST@"/Service/Resistance/List"
//删除抗性反馈
extern NSString *const Remove_Resistance_Url;// HOST@"/Service/Resistance/Delete"
//新闻中心top图片
extern NSString *const News_Top_Image_Url;// HOST@"/Service/Ppt/NewsPptList"
//新闻中心数据
extern NSString *const News_List_Data_Url;// HOST@"/Service/News/List"
//新闻详情
extern NSString *const News_Detail_Url;// HOST@"/Service/News/Detail?id="

//收藏新闻
extern NSString *const Collect_News_Url;// HOST@"/Service/Collect/NewsAdd"
//移除收藏新闻
extern NSString *const Remove_Collect_News_Url;// HOST@"/Service/Collect/NewsDelete"

//添加抗性反馈
extern NSString *const Add_Resistance_Data_Url;// HOST@"/Service/Resistance/Add"
//抗性反馈回复
extern NSString *const Add_Resistance_Comment_Url;// HOST@"/Service/Resistance/AddComment"
//抗性反馈评论列表
extern NSString *const Resistance_Comment_List_Url;// HOST@"/Service/Resistance/CommentList"
//赞一下抗性反馈
extern NSString *const Zan_Resistance_Url;// HOST@"/Service/Resistance/Zan"

//根据类别获取产品列表
extern NSString *const Product_List_Url;// HOST@"/Service/Product/List"
//产品详情
extern NSString *const Product_Detail_Url;// HOST@"/Service/Product/Detail?id="

//杂草列表
extern NSString *const Weed_List_Url;// HOST@"/Service/Weed/List"
//杂草详情
extern NSString *const Weed_Detail_Url;// HOST@"/Service/Weed/Detail?id="

//收藏杂草
extern NSString *const Collect_Weed_Url;// HOST@"/Service/Collect/WeedAdd"
//移除收藏杂草
extern NSString *const Remove_Collect_Weed_Url;// HOST@"/Service/Collect/WeedDelete"

//会员认证
extern NSString *const User_Certification_Url;// HOST@"/Service/Content/WebView?title="

//意见反馈
extern NSString *const Feed_Opinion_Url;// HOST@"/Service/Option/Index"

//修改密码
extern NSString *const Changed_Password_Url;// HOST@"/Service/User/UpdatePassword"

//杂草收藏列表
extern NSString *const Weed_Collection_List_Url;// HOST@"/Service/Collect/WeedList"
//新闻收藏列表
extern NSString *const News_Collection_List_Url;// HOST@"/Service/Collect/NewsList"
//咨询收藏列表
extern NSString *const Consultation_Collection_List_Url;// HOST@"/Service/Collect/ProQuestionList"

//咨询记录列表
extern NSString *const ProQuestion_List_Url;// HOST@"/Service/ProQuestion/Search"

//获取咨询回复列表
extern NSString *const Consultation_Repley_List_Url;// HOST@"/Service/ProQuestion/CommentList"

//收藏咨询
extern NSString *const Collection_Consultation_Url;// HOST@"/Service/Collect/ProQuestionAdd"
//移除收藏咨询
extern NSString *const Remove_Collection_Consultation_Url;// HOST@"/Service/Collect/ProQuestionDelete"

//咨询赞
extern NSString *const Zan_Consultation_Url;// HOST@"/Service/ProQuestion/Zan"

//咨询评论及回复评论
extern NSString *const Repley_Consultation_Url;// HOST@"/Service/ProQuestion/Comment"

//向专家咨询
extern NSString *const Quest_Consultation_Url;// HOST@"/Service/ProQuestion/Add"

//除试验记录
extern NSString *const Experiment_List_Url;// HOST@"/Service/Experience/List"
//试验记录
extern NSString *const Only_Experiment_List_Url;// HOST@"/Service/Experience/CircleList"

//获取人员姓名list
extern NSString *const Get_People_List_Url;// HOST@"/Service/Experience/DelegateUserList"
//试验记录获取人员姓名list
extern NSString *const Get_Experiment_People_List_Url;// HOST@"/Service/Experience/DelegateCircleUserList"

//获取药剂名称list
extern NSString *const Get_Medicament_List_Url;// HOST@"/Service/Product/FirstLetterList"

////获取天气
extern NSString *const Get_Weather_Url;// HOST@"/Service/Weather/Index_v2?"
//添加试验
extern NSString *const Add_Experiment_Url;// HOST@"/Service/Experience/AddExperience"
//获取单个杂草详情
extern NSString *const Get_Weed_Detail_Url;// HOST@"/Service/Weed/GetById"

//获取观摩详情
extern NSString *const Get_GuanMo_Detail_Url;// HOST@"/Service/Experience/GetExperienceItemById"

//添加 观察 观摩
extern NSString *const Add_GuanMo_Url;// HOST@"/Service/Experience/addExperienceItem"

//添加追踪
extern NSString *const Add_Follow_Url;// HOST@"/Service/Experience/AddFollow"

//添加评价
extern NSString *const Add_Judge_Url;// HOST@"/Service/Experience/AddExperienceItemComment"

//委托
extern NSString *const Delegate_User_Url;// HOST@"/Service/Experience/AddDelegate"

//归档
extern NSString *const Filing_Experiment_Url;// HOST@"/Service/Experience/UpdateStatus"
//用户信息保存
extern NSString *const UserInfo_Data_Save_Url;// HOST@"/Service/User/UpdateInfo"
//经销商认证
extern NSString *const UserInfo_Dealis_Confirm_Url;// HOST@"/Service/User/UpdateUserDistributor"
//零售商认证
extern NSString *const UserInfo_Realis_Confirm_Url;// HOST@"/Service/User/UpdateUserRetailer"
//农场主认证
extern NSString *const UserInfo_Famer_Confirm_Url;// HOST@"/Service/User/UpdateUserFarmer"
//获取其他用户的信息
extern NSString *const OtherUserInfo_ById_Url;// HOST@"/Service/User/GetUserById"

//获取自己的用户信息
extern NSString *const Get_UserInfo_Url;// HOST@"/Service/User/CurrentUser"

//拜访记录
extern NSString *const Visiting_List_Url;// HOST@"/Service/VisitRecord/List"

//添加拜访记录
extern NSString *const Add_Visiting_Url;// HOST@"/Service/VisitRecord/Add"

//圈子列表
extern NSString *const Circle_List_Url;// HOST@"/Service/Circle/List_v2"
//圈子搜索
extern NSString *const Circle_Search_Url;// HOST@"/Service/Circle/SearchUserList"
//圈人(圈人确认)
//#define Circle_People_Url HOST@"/Service/Circle/Invite"
//圈人（审批流程）
extern NSString *const Circle_People_Url;// HOST@"/Service/Approve/AddCircleApprove"

//专家咨询搜索
extern NSString *const Consult_Search_Url;// HOST@"/Service/ProQuestion/Search"
//杂草中心搜索
extern NSString *const Weed_Search_Url;// HOST@"/Service/Weed/List"
//产品中心搜索
extern NSString *const Product_Search_Url;// HOST@"/Service/Product/List"
//新闻列表搜索
extern NSString *const News_Search_URL;// HOST@"/Service/News/List"
//抗联助手
extern NSString *const Amy_assistant_Url;// HOST@"/Service/MsgCenter/List"
//抗联助手发送信息
extern NSString *const Send_Message_Url;//  HOST@"/Service/MsgCenter/TalkWithHelper"
//消息列表详情
extern NSString *const MessageDetail_List_URL;// HOST@"/Service/MsgCenter/List"
//我的咨询  和检索
extern NSString *const MineConsulation_List_URL;// HOST@"/Service/ProQuestion/List"
//圈子咨询  和检索
extern NSString *const CycleConsulation_List_URL;// HOST@"/Service/ProQuestion/CircleList"
//根据id获取咨询model
extern NSString *const Consultation_DetailById_URL;// HOST@"/Service/ProQuestion/GetById"
//我的调查 我的采集 我的反馈
extern NSString *const Message_Mine_SevWeedResis_URL;// HOST@"/Service/Resistance/MyList"
//圈子调查  圈子采集  圈子反馈
extern NSString *const Message_Cycle_SevWeedResis_URL;// HOST@"/Service/Resistance/CircleList"
//获取消息首页列表
extern NSString *const Get_Message_List_Url;// HOST@"/Service/MsgCenter/GroupList"
//根据id获取抗性反馈  抗性调查  种子采集 model
extern NSString *const ResistanceBackSuarveWeed_Detail_ById_URL;// HOST@"/Service/Resistance/GetById"
//我的种子 反馈 调查 检索
extern NSString *const MineSeedResisBackSurvey_Search_URL;// HOST@"/Service/Resistance/MyList"
//圈子 种子 反馈 调查检索
extern NSString *const CycleSeedResisBackSurvey_Search_URL;// HOST@"/Service/Resistance/CircleList"
//新闻详情model
extern NSString *const NewsDtail_Model_Url;// HOST@"/Service/News/GetById?"
//获取验证码
extern NSString *const Get_Code_Data_Url;// HOST@"/Service/User/SendSms"
//注册
extern NSString *const Register_User_Url;// HOST@"/Service/User/Register"
//找回密码
extern NSString *const Forget_Password_Url;// HOST@"/Service/User/FindPassword"
////
extern NSString *const Sale_Product_List_Url;// HOST@"/Service/Product/AllList"
//获取示范试验model
extern NSString *const Tets_Model_Url;// HOST@"/Service/Experience/GetExperienceById?"
//我的试验
extern NSString *const My_Experiment_Url;// HOST@"/Service/Experience/MyList"
//圈子试验
extern NSString *const Circl_Experiment_Url;// HOST@"/Service/Experience/CircleList"
//圈人拒绝Url
extern NSString *const Circle_People_Refuse_Url;// HOST@"/Service/Circle/RefuseInvite"
//圈人同意
extern NSString *const Circle_People_Agree_Url;// HOST@"/Service/Circle/ConfirmInvite"
//密室列表
extern NSString *const Secret_List_Url;// HOST@"/Service/SecretHouse/List"
//密室发送
extern NSString *const Secret_Sender_Url;// HOST@"/Service/SecretHouse/Add"
//发现附近列表
extern NSString *const Find_Near_List_URL;// HOST@"/Service/NearbyPeople/List"

//除草圈列表
extern NSString *const Weeding_Circle_List_Url;// HOST@"/Service/WeedCircle/List"
//防伪追踪
extern NSString *const QR_code_Url;// HOST@"/Service/InventoryVipCenter/SecurityCheck"

//赞  取消赞
extern NSString *const Weeding_Zan_Url;// HOST@"/Service/WeedCircle/AddZan"
extern NSString *const Weeding_Remove_Zan_Url;// HOST@"/Service/WeedCircle/RemoveZan"

//除草圈回复评论
extern NSString *const Weeding_Comment_Url;// HOST@"/Service/WeedCircle/AddComment"

//获取人员除草圈列表
extern NSString *const Get_User_Weeding_List_Url;// HOST@"/Service/WeedCircle/MyList"

//添加除草圈
extern NSString *const Add_Weeding_Data_Url;// HOST@"/Service/WeedCircle/Add"
//消息已读
extern NSString *const MessageList_Is_Reading_URL;// HOST@"/Service/Jpush/ReadJpush"
//整组已读
extern NSString *const MessageGroup_IsReader_Url;// HOST@"/Service/MsgCenter/ReadGroup"

//获取广告页
extern NSString *const Get_Ad_List_Data_Url;// HOST@"/Service/Ppt/GuidePptList"
//拜访记录所属列表
extern NSString *const Visit_Belong_List_Data_URL;// HOST@"/Service/VisitRecord/List"
//我的圈子列表
extern NSString *const MyCycle_Data_List_URL;// HOST@"/Service/Circle/MyCircleUserList"
///Service/User/GetUserById

//移除除草圈信息
extern NSString *const Remove_Weeding_Circle_Data_Url;// HOST@"/Service/WeedCircle/RemoveCircle"
//移除除草圈评论信息
extern NSString *const Remove_Weeding_Comment_Url;// HOST@"/Service/WeedCircle/RemoveCircleComment"
//圈子移除用户
extern NSString *const Circle_Delete_user_Url;// HOST@"/Service/Circle/DeleteCircleUser"
///圈子移除组织
extern NSString *const Circle_Delete_Orginse_URL;// HOST@"/Service/Circle/DeleteCircle"
//获取我的仓库列表
extern NSString *const MyWarehouse_List_Url ;//HOST@"/Service/Store/MyList"
//出库订单列表
extern NSString *const Come_Warehouse_Url;// HOST@"/Service/Store/outList"
//删除当前用户的当前位置
extern NSString *const Delete_User_Location_URL;// HOST@"/Service/NearbyPeople/Delete"
//扫码获取产品模型
extern NSString *const Scan_Get_Product_Model_Url;// HOST@"/Service/Store/GetProductByCartonCode"

//出货选择人列表
extern NSString *const Scan_Product_People_List_Url;// HOST@"/Service/Circle/MyCircleUserList"
//出库
extern NSString *const Scan_Product_Finished_Url;// HOST@"/Service/Store/OutStore"
//订单列表
extern NSString *const My_Order_Data_List_URL;// HOST@"/Service/Order/MyList"
//确认收货
extern NSString *const Confirm_Order_Accevie_Status_URL;// HOST@"/Service/Order/ConfirmReceive"

//除草圈未读
extern NSString *const Weeding_Circle_UnReader_Url;// HOST@"/Service/WeedCircle/IsWeedCircleRead"
//版本检测
extern NSString *const KangLian_Verson_Updata_URL;// HOST@"/Service/Update/IosVersion"

//勿扰模式
extern NSString *const Disturb_Switch_Url;// HOST@"/Service/User/SetSlientMode"

//获取未读消息
extern NSString *const Get_UnReader_Message_Url;// HOST@"/Service/MsgCenter/LatestPushInfo"
//考试数据
extern NSString *const GameCenter_Text_Data_URL;// HOST@"/Service/ExamTest/GetPaperExamList_v2"
//考试类型
extern NSString *const GameCenter_Text_Soft_URL;// HOST@"/Service/ExamTest/GetPaperList"
//提交所有试卷
extern NSString *const PostText_Answer_Url;// HOST@"/Service/ExamTest/PostAllDetails_v2"
//提交单个试题答案
extern NSString *const Post_Single_Answer_URL;// HOST@"/Service/ExamTest/PostDetail"
//答题剩余时间
extern NSString *const Text_Remaine_Time_URL;// HOST@"/Service/ExamTest/GetLastTime"
//疯狂识草获取所有题目
extern NSString *const Get_Grass_URL;// HOST@"/Service/WildGrass/GetListByTypeId"
//疯狂识草提交答案
extern NSString *const Submit_Grass_Answer_URL;// HOST@"/Service/WildGrass/SubmitAnswer"
//清除当前用户位置信息
extern NSString *const Clear_User_Location_Info_URL;// HOST@"/Service/NearbyPeople/Delete"
//专家咨询收藏
extern NSString *const Expert_Consult_Collecte_URL;// HOST@"/Service/ProQuestion/CollectList"
//专家咨询点赞
extern NSString *const Expert_Consult_Zan_URL;// HOST@"/Service/ProQuestion/ZanList"
//除草圈未读消息列表
extern NSString *const Wedd_Circle_UnReadMessage_URL;// HOST@"/Service/WeedCircle/UnReadMsgList"
//获取除草圈未读消息数
extern NSString *const Get_Weeding_UnReader_Count_URL;// HOST@"/Service/WeedCircle/UnReadMsgCount"
//获取用户除草圈背景图片
extern NSString *const Get_User_Weeding_bgImg_URL;// HOST@"/Service/WeedCircle/GetBackground"
//（根据id获得单条除草圈信息）
extern NSString *const Wedd_Circle_Singal_Byid_URL;// HOST@"/Service/WeedCircle/GetById"
//（清空除草圈提示信息）
extern NSString *const Clear_WeedMessage_List_URL;// HOST@"/Service/WeedCircle/ClearAllTip"
//修改除草圈背景图片
extern NSString *const Changed_User_Weeding_bgImg_URL;// HOST@"/Service/WeedCircle/UpdateBackground"

//通用上传图片接口
extern NSString *const Template_Updata_Img_Url;// HOST@"/Service/Upload/Multi"

//添加零售商
extern NSString *const Add_CircleUser_Url;// HOST@"/Service/Circle/AddUser"
//修改零售商信息
extern NSString *const Edit_CircleUser_Url;// HOST@"/Service/Circle/EditUser"

//零售商销售信息列表
extern NSString *const Sale_Info_List_Url;// HOST@"/Service/Circle/SaleInfoList"

//销售类别数据
extern NSString *const Sale_Type_Data_Url;// HOST@"/Service/Circle/SaleInfoTypeList"

//圈子检索接口
extern NSString *const Circle_Retrieval_Url;// HOST@"/Service/Circle/Search"

//圈子路径接口
extern NSString *const Circle_Link_Url;// HOST@"/Service/Circle/RouteList"
//经销商。零售商 详情
extern NSString *const Merchant_Details_Url;// HOST@"/Service/Circle/GetBaseInfo"
//经销商零售商年份销售年份
extern NSString *const Get_Year_Info_Url;// HOST@"/Service/Circle/SaleInfoGroupList"
//添加销售信息
extern NSString *const Add_Sale_Info_url;// HOST@"//Service/Circle/EditSale?"
//获取年销售信息详情
extern NSString *const Get_Year_Sael_Info_Url;//  HOST@"/Service/Circle/SaleInfoListByYear"
///组织编辑
extern NSString *const Circle_Orginse_Ediate_URL;// HOST@"/Service/Circle/UpdateCircle"
///添加组织
extern NSString *const Add_Circle_Orginse_URL;// HOST@"/Service/Circle/AddCircle"
//提交销售信息
extern NSString *const Submit_Sale_Info_Url;// HOST@"/Service/Circle/UpdateBaseInfo"
//获取地图图片
extern NSString *const Get_Map_Image_Url;// @"http://api.map.baidu.com/staticimage/v2?"
///农场主信息采集列表
extern NSString *const Info_Collection_Url;// HOST@"/Service/Circle/FarmerCollectList"
//新增农场主采集信息
extern NSString *const New_Add_CollectionInfo_Url;// HOST@"/Service/Circle/AddFarmerCollection"
///圈子管理人员列表
extern NSString *const Circle_Manager_Selettion_URL;// HOST@"/Service/Circle/CircleExistUserList"
///编辑专家
extern NSString *const Ediate_Circle_Expert_URL;// HOST@"/Service/Circle/UpdateExpert"
///添加专家
extern NSString *const Add_Circle_Expert_URL;// HOST@"/Service/Circle/AddExpert"
///编辑经销商
extern NSString *const Ediate_Circle_Distributor_URL;// HOST@"/Service/Circle/UpdateUserDistributor"
///添加经销商
extern NSString *const Add_Circle_Distributor_URL;// HOST@"/Service/Circle/AddUserDistributor"
///编辑零售商
extern NSString *const Ediate_Circle_Retailer_URL;// HOST@"/Service/Circle/UpdateUserRetailer"
///添加零售商
extern NSString *const Add_Circle_Retailer_URL;// HOST@"/Service/Circle/AddUserRetailer"
///编辑农场主
extern NSString *const Ediate_Circle_Famer_URL;// HOST@"/Service/Circle/UpdateUserFarmer"
///添加农场主
extern NSString *const Add_Circle_Famer_URL;// HOST@"/Service/Circle/AddUserFarmer"
///圈子管理删除人员
extern NSString *const Delete_Circle_Member_URL;// HOST@"/Service/Circle/RemoveCircleUser"

//新版本介绍
extern NSString *const New_Version_Info_Url;// HOST@"/Service/Update/IosWebView?isIos=1"

///获取抗性地图数据
extern NSString *const Get_GResistance_List_Url;// HOST@"/Service/Resistance/GetListByPosition"
////
extern NSString *const GetNew_GResistence_List_url;// HOST@"/Service/Resistance/GetStatisticsList"
///获取他人抗性反馈列表
extern NSString *const Get_Others_GResistance_List_Url;// HOST@"/Service/Resistance/GetListByUser"
//获取委托机构
extern NSString *const Get_Entrusted_Agency_List_Url;// Prevent_HOST@"/Service/InventoryVipCenter/GetAgentByID"
//签收入库
extern NSString *const Receipt_And_Atorage_Url;// Prevent_HOST@"/Service/InventoryVipCenter/SignIn"

//物流信息
extern NSString *const Get_logistics_Info_Url;// Prevent_HOST@"/Service/InventoryVipCenter/GetLogisticsListByOrderNo"
//获取调入机构
extern NSString *const Get_Call_Institutions_Url;// HOST@"/Service/Circle/GetInCircleList_Ext"


// 删除消息
 

extern NSString *const Delete_Message_Url;// HOST@"/Service/MsgCenter/DeleteMsg"

///获取地址信息
extern NSString *const Get_Addess_Info_Url;// HOST@"/Service/BaseInfo/AreaList?"



// 获取配置项
extern NSString *const Get_App_Config_Path;// HOST@"/Service/DataConfig/GetByVersion"

//获取杂草名称
extern NSString *const Get_WeedsName_Url;// HOST@"/Service/Resistance/GetWeedName"

// 计算面积
extern NSString *const Get_Area_Url;// HOST@"/Service/Experience/CalcArea"


extern NSString *const Get_DrugList_Url;// HOST@"/Service/Resistance/GetResistanceDrugs"
 //获取审批功能列表
extern NSString *const Get_Approve_Model_List_Url;// HOST@"/Service/Approve/GetUserApproveList"
// 提交审批web页面

extern NSString *const Add_Approve_Web_Url;// HOST@"/Service/Approve/AddView"
//提交种子品种
extern NSString *const Add_SeedCollection_Url;// HOST@"/Service/Seed/Add"
///查询种子品种
extern NSString *const Search_SeedCollection_Url;// HOST@"/Service/Seed/List"



@end
