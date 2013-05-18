//
//  BaiduMobAdDelegateProtocol.h
//  BaiduMobAdSdk
//
//  Created by jaygao on 11-9-8.
//  Copyright 2011年 Baidu. All rights reserved.
//
//  Baidu Mobads SDK Version 3.0
//

/**
 *  性别类型
 */
typedef enum
{
	BaiduMobAdMale=0,
	BaiduMobAdFeMale=1,   
    BaiduMobAdSexUnknown=2,
} BaiduMobAdUserGender;

/**
 *  广告展示失败类型枚举
 */
typedef enum _BaiduMobFailReason
{
    BaiduMobFailReason_NOAD = 0,
    // 没有推广返回
    BaiduMobFailReason_EXCEPTION 
    //网络或其它异常
} BaiduMobFailReason;

///---------------------------------------------------------------------------------------
/// @name 协议板块
///---------------------------------------------------------------------------------------

@class BaiduMobAdView;
/**
 *  广告sdk委托协议
 */
@protocol BaiduMobAdViewDelegate<NSObject>

@required
/**
 *  应用在mounion.baidu.com上的id
 */
- (NSString *)publisherId;

/**
 *  应用在mounion.baidu.com上的计费名
 */
- (NSString*) appSpec;

@optional
/**
 *  启动位置信息
 */
-(BOOL) enableLocation;

/**
 *  广告将要被载入
 */
-(void) willDisplayAd:(BaiduMobAdView*) adview;

/**
 *  广告载入失败
 */
-(void) failedDisplayAd:(BaiduMobFailReason) reason;


///---------------------------------------------------------------------------------------
/// @name 人群属性板块
///---------------------------------------------------------------------------------------

/**
 *  关键词数组
 */
-(NSArray*) keywords;

/**
 *  用户性别
 */
-(BaiduMobAdUserGender) userGender;

/**
 *  用户生日
 */
-(NSDate*) userBirthday;

/**
 *  用户城市
 */
-(NSString*) userCity;


/**
 *  用户邮编
 */
-(NSString*) userPostalCode;


/**
 *  用户职业
 */
-(NSString*) userWork;

/**
 *  - 用户最高教育学历
 *  - 学历输入数字，范围为0-6
 *  - 0表示小学，1表示初中，2表示中专/高中，3表示专科
 *  - 4表示本科，5表示硕士，6表示博士
 */
-(NSInteger) userEducation;

/**
 *  - 用户收入
 *  - 收入输入数字,以元为单位
 */
-(NSInteger) userSalary;

/**
 *  用户爱好
 */
-(NSArray*) userHobbies;

/**
 *  其他自定义字段,key以及value都为NSString
 */
-(NSDictionary*) userOtherAttributes;

@end