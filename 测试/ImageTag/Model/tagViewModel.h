//
//  tagViewModel.h
//  测试
//
//  Created by apple on 2017/6/21.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tagViewModel : NSObject

@property (nonatomic ,assign) BOOL isAudio;
@property (nonatomic ,assign) BOOL positiveAndNegative; //正向 反向

@property (nonatomic ,assign) float viewTagPointX;
@property (nonatomic ,assign) float viewTagPointY;

//@property (nonatomic ,assign) float redPointX;
//@property (nonatomic ,assign) float redPointY;

@property (nonatomic ,assign) float CircleStarPointX;
@property (nonatomic ,assign) float CircleStarPointY;

@property (nonatomic ,assign) float CircleCenterPointX;
@property (nonatomic ,assign) float CircleCenterPointY;


@property (nonatomic ,copy) NSString *text;
@property (nonatomic ,strong) NSData *AudioUrl;

@property (nonatomic ,copy) NSString *audioTime;

@end
