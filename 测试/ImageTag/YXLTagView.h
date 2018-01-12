//
//  YXLTagView.h
//  YXLImageLabelDemo
//
//  Created by 叶星龙 on 15/10/26.
//  Copyright © 2015年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXLWaterFlowImageView.h"
#import "pch.h"


#import "XHAudioImageView.h"

@interface YXLTagView : UIView



/**
 *  判断是否是 音频 NO and YES
 */
@property (nonatomic ,assign) BOOL isAudio;


/**
 *  判断是否是正向和反向 NO and YES
 */
@property (nonatomic ,assign) BOOL isPositiveAndNegative;
/**
 *  标签图片+文本
 */
@property (nonatomic ,strong) YXLWaterFlowImageView *imageLabel;

/**
 *  audio+ 时间
 */
@property (nonatomic ,strong) XHAudioImageView *audioViewLabel;

@property (nonatomic ,strong) NSData *audio_data;

@property (nonatomic ,strong) NSData *audio_Url; //音频 链接  学生端用的


/**
 *  最开始点击是不显示标签图片只显示一个点  默认NO : 不显示标签 NO And 显示 YES
 */
@property (nonatomic ,assign) BOOL isImageLabelShow;




@end
