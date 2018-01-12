//
//  annotateAndCommentView.h
//  测试
//
//  Created by apple on 2017/6/19.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

//批注



#import <UIKit/UIKit.h>

typedef void(^selectBlock)( BOOL isSure , NSString *text);


@interface annotateAndCommentView : UIView

+ (annotateAndCommentView *)shared;

- (void)showViewWithSelectBlock:(selectBlock)block;

@property (nonatomic ,copy) selectBlock block;

@end
