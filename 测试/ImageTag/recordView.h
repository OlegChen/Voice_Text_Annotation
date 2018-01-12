//
//  recordView.h
//  测试
//
//  Created by apple on 2017/6/19.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

//录音

#import <UIKit/UIKit.h>


typedef void(^completeBlock)( BOOL isSure , NSData *data ,NSString *time);


@interface recordView : UIView


+ (recordView *)shared;

- (void)showRecordViewWithBlock:(completeBlock)block;

@property (nonatomic ,copy) completeBlock block;

- (NSString *)recordPath;

@end
