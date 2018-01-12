//
//  myDrawShapeLayer.h
//  测试
//
//  Created by apple on 2017/6/16.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface myDrawShapeLayer : CAShapeLayer

@property (nonatomic ,assign) int tag;


@property (nonatomic ,assign) CGPoint prePoint;
@property (nonatomic ,assign) CGPoint endPoint;

@property (nonatomic ,assign) CGPoint circlePoint;


@property (nonatomic ,assign) CGPoint lineEndPoint;



@end
