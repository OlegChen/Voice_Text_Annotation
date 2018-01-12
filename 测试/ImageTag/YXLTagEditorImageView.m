//
//  YXLTagEditorImageView.m
//  YXLImageLabelDemo
//
//  Created by 叶星龙 on 15/10/26.
//  Copyright © 2015年 叶星龙. All rights reserved.
//

#import "YXLTagEditorImageView.h"
#import "YXLTagView.h"
#import "MiYiTagSearchBarVC.h"

#import "myDrawShapeLayer.h"

#import "annotateAndCommentView.h"
#import "recordView.h"
#import "LGAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


#import "LGSoundRecorder.h"


@interface YXLTagEditorImageView ()<UIGestureRecognizerDelegate,LGAudioPlayerDelegate>
{
    NSMutableArray *arrayTagS;
    UIView *viewCover;
    UIView *viewMBP;
    UIButton *buttonOne;
    UIButton *buttonTwo;
    YXLTagView *viewTag;
    CGFloat imageScale;
    UIImage *imageLabelIcon;
    CGFloat viewTagLeft;
    NSMutableArray *arrayInitDidView;
    BOOL isViewDidLoad;
    
}

@property (nonatomic ,strong) UIColor *lineColor;   //绘制颜色

@property (nonatomic ,strong) UIColor *textLineColor;   //文本颜色
@property (nonatomic ,strong) UIColor *audioLineColor;   //音频颜色


@property (nonatomic ,strong) myDrawShapeLayer *currentLayer;

@property (nonatomic ,strong) NSMutableArray *circleLayerArr;
@property (nonatomic ,strong) NSMutableArray *lineLayerArr;

//空间 tag
@property (nonatomic ,assign) int tagNum;

@end

@implementation YXLTagEditorImageView

-(id)initWithImage:(UIImage *)image{
    self =[super init];
    if (self) {
        arrayInitDidView= [NSMutableArray array];
        imageLabelIcon =[UIImage imageNamed:@"textTag"];
        arrayTagS =[NSMutableArray array];
        _imagePreviews =[self getimagePreviews];
        _imagePreviews.userInteractionEnabled=YES;
        [self addSubview:_imagePreviews];
        if (image==nil) {
            return self;
        }
        _imagePreviews.image =image;
        [self scaledFrame];
        [self initTagUI];
        
                
        
    }
    return self;
}

-(id)init{
    self =[super init];
    if (self) {
        if (imageLabelIcon==nil) {
            imageLabelIcon =[UIImage imageNamed:@"textTag"];
        }
        if (arrayTagS==nil) {
            arrayTagS =[NSMutableArray array];
        }
        if (arrayInitDidView==nil) {
            arrayInitDidView= [NSMutableArray array];
        }
        if (_imagePreviews==nil) {
            _imagePreviews =[self getimagePreviews];
            _imagePreviews.userInteractionEnabled=YES;
            [self addSubview:_imagePreviews];
            [self initTagUI];
        }
        
        
    }
    return self;
}

/**
 *  初始化MBP界面
 */
-(void)initTagUI{
    
    
    self.lineColor = [UIColor greenColor];

    self.textLineColor = [UIColor orangeColor];
    self.audioLineColor = [UIColor blueColor];

    
    viewCover =[UIView new];
    viewCover.alpha=0;
//    viewCover.backgroundColor = [UIColor redColor];
    [self addSubview:viewCover];
    [viewCover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    viewMBP =[UIView new];
//    viewMBP.backgroundColor = [UIColor blueColor];
    //弹出按钮消失手势
    UITapGestureRecognizer* viewMBPTag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewMBP)];
    viewMBPTag.numberOfTapsRequired=1;
    viewMBPTag.numberOfTouchesRequired=1;
    viewMBPTag.delegate = self;
    
    [viewMBP addGestureRecognizer:viewMBPTag];
    [viewCover addSubview:viewMBP];
    [viewMBP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    //画图手势
    self.tagNum = 100;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePanGestures:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.delaysTouchesEnded = NO;
    [_imagePreviews addGestureRecognizer:panGestureRecognizer];


    
    CGFloat widthAndHeight =100;
    
    buttonOne =[self getButtonOne];
    buttonOne.layer.cornerRadius=widthAndHeight/2;
    [viewCover addSubview:buttonOne];
    [buttonOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-(widthAndHeight/1.3));
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(widthAndHeight, widthAndHeight));
    }];
    
    buttonTwo =[self getButtonTwo];
    buttonTwo.layer.cornerRadius=widthAndHeight/2;
    [viewCover addSubview:buttonTwo];
    [buttonTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(widthAndHeight/1.3);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(widthAndHeight, widthAndHeight));
    }];
}
/**
 *  mbp界面的动画
 */
-(void)mbpAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.1 animations:^{
            viewCover.alpha=1;
            buttonOne.transform=CGAffineTransformMakeScale(1.2, 1.2);
            buttonTwo.transform=CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
                buttonOne.transform=CGAffineTransformIdentity;
                buttonTwo.transform=CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                
            }];
        }];
    }else{
        [UIView animateWithDuration:0.1 animations:^{
            viewCover.alpha=0;
        }completion:^(BOOL finished) {
            if (arrayTagS.count !=0) {
                YXLTagView *tag =[arrayTagS lastObject];
                if (!tag.isImageLabelShow) {
                    [tag removeFromSuperview];
                    [arrayTagS removeLastObject];
                    
                    myDrawShapeLayer *line = self.lineLayerArr.lastObject;
                    [line removeFromSuperlayer];
                    [self.lineLayerArr removeLastObject];
                    
                    
                    myDrawShapeLayer *circle = self.circleLayerArr.lastObject;
                    [circle removeFromSuperlayer];
                    [self.circleLayerArr removeLastObject];
                    

                    
                }
            }
        }];
        
    }
    
}

#pragma -mark 添加已知标签
//
//-(void)addTagViewText:(NSString *)text Location:(CGPoint )point isPositiveAndNegative:(BOOL)isPositiveAndNegative{
//    CGFloat X;
//    if (isPositiveAndNegative) {
//        X = point.x*imageScale-8;
//    }else{
//        X = point.x*imageScale;
//    }
//    CGPoint pointimageScale =CGPointMake(X, point.y*imageScale+imageLabelIcon.size.height/2);
//    [self addtagViewimageClickinit:pointimageScale isAddTagView:YES];
//    if(text.length!=0)
//        viewTag.imageLabel.labelWaterFlow.text=text;
//    
//    if(isPositiveAndNegative==NO){
//        [self layoutIfNeeded];
//        [self viewTagIsPositiveAndNegative:isPositiveAndNegative view:viewTag];
//    }
//}


- (void)addTagViewWithModel:(tagViewModel *)model{
    
    UIColor *color = model.isAudio ? self.audioLineColor : self.textLineColor;
    
//    CGRect newRect = CGRectMake(model.CircleStarPointX *imageScale ,  model.CircleStarPointY *imageScale ,fabs(model.CircleStarPointX *imageScale - model.CircleCenterPointX *imageScale) * 2 , fabs(model.CircleStarPointY *imageScale - model.CircleCenterPointY *imageScale) * 2);
//    [self drawBallLayerWithRect:newRect WithColor:color WithLayer:self.currentLayer];
    [self setCircleShapeLayerWithPrePoint:CGPointMake(model.CircleStarPointX *imageScale , model.CircleStarPointY *imageScale ) circlePoint:CGPointMake(model.CircleCenterPointX * imageScale, model.CircleCenterPointY * imageScale) WithColor:color];
    
    
    myDrawShapeLayer *lineLayer = [self setLineFromCirclePoint:CGPointMake(model.CircleCenterPointX  *imageScale, model.CircleCenterPointY  *imageScale) toPoint:CGPointMake(model.viewTagPointX  *imageScale, model.viewTagPointY  *imageScale + 10) WithColor:color WithView:self];
    lineLayer.tag = self.currentLayer.tag;
    lineLayer.circlePoint = self.currentLayer.circlePoint;
    lineLayer.lineEndPoint = CGPointMake((self.currentLayer.circlePoint.x +  MIN(self.currentLayer.prePoint.x, self.currentLayer.endPoint.x)  ) / 2.0, MIN(self.currentLayer.prePoint.y, self.currentLayer.endPoint.y) - 10  );
    [_imagePreviews.layer addSublayer:lineLayer];
    [self.lineLayerArr addObject:lineLayer];

    
    
    CGFloat X;
    if (model.positiveAndNegative) {
        X = model.viewTagPointX * imageScale-8;
    }else{
        X = model.viewTagPointX * imageScale;
    }
    CGPoint pointimageScale =CGPointMake(X, model.viewTagPointY * imageScale + imageLabelIcon.size.height/2);
    [self addtagViewimageClickinit:pointimageScale isAddTagView:YES];
    
    viewTag.isAudio = model.isAudio;
    if (model.isAudio) {
        
        viewTag.audio_Url = model.AudioUrl;
        viewTag.audioViewLabel.labelTime.text = model.audioTime;
    }else{
    
        if(model.text.length!=0){
            viewTag.imageLabel.labelWaterFlow.text= model.text;

        }
    }
    viewTag.isImageLabelShow=YES;


        if(model.positiveAndNegative == NO){
            [self layoutIfNeeded];
            [self viewTagIsPositiveAndNegative:model.positiveAndNegative view:viewTag];
        }

    
}


#pragma -mark 点击创建标签
-(void)addtagViewimageClickinit:(CGPoint)point isAddTagView:(BOOL)isAdd{
    YXLTagView *viewTagNew =[[YXLTagView alloc]init];
    viewTagNew.tag = self.tagNum;
    UIPanGestureRecognizer *panTagView =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTagView:)];
    panTagView.minimumNumberOfTouches=1;
    panTagView.maximumNumberOfTouches=1;
    panTagView.delegate=self;

    [viewTagNew addGestureRecognizer:panTagView];
    
    UITapGestureRecognizer* tapTagView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTagView:)];
    tapTagView.numberOfTapsRequired=1;
    tapTagView.numberOfTouchesRequired=1;
    tapTagView.delegate = self;
    [viewTagNew addGestureRecognizer:tapTagView];
    
    UILongPressGestureRecognizer *longTagView =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTagView:)];
    longTagView.minimumPressDuration=0.5;
    longTagView.delegate=self;
    [viewTagNew addGestureRecognizer:longTagView];
    [_imagePreviews addSubview:viewTagNew];
    
    [viewTagNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(point.x));
        make.top.equalTo(@(point.y-imageLabelIcon.size.height/2));
        make.width.greaterThanOrEqualTo(@(65));//viewTagNew.imageLabel.image.size.width+8));
        make.height.equalTo(@(imageLabelIcon.size.height));
    }];
    
    [arrayTagS addObject:viewTagNew];
    viewTag=viewTagNew;
    if (!isAdd) {
        [self mbpAnimation:YES];
    }else{
        viewTagNew.isImageLabelShow=YES;
    }
    
    
}


#pragma -mark GestureRecognizer
/**
 *  标签移动
 */
-(void)panTagView:(UIPanGestureRecognizer *)sender{
    viewTag =(YXLTagView *)sender.view;
    
    myDrawShapeLayer *lineLayer;
    
    for (myDrawShapeLayer *line in  self.lineLayerArr) {
        
        if (line.tag == viewTag.tag) {
            
            lineLayer = line;
            
            break;

        }
        
    }
    
    
    CGPoint point = [sender locationInView:_imagePreviews];
    if (sender.state ==UIGestureRecognizerStateBegan) {
        viewTagLeft =point.x-CGOriginX(viewTag.frame);
    }
    
   
    [self panTagViewPoint:point withLineLayer:lineLayer];
}
/**
 *  点击标签  -- 播放音频
 */
-(void)tapTagView:(UITapGestureRecognizer *)sender{
    viewTag =(YXLTagView *)sender.view;
    [self viewTagIsPositiveAndNegative:viewTag.isPositiveAndNegative view:viewTag];
}
/**
 *  长按手势
 */
-(void)longTagView:(UILongPressGestureRecognizer *)sender{
    viewTag =(YXLTagView *)sender.view;
    if (sender.state ==UIGestureRecognizerStateBegan) {
        [sender.view becomeFirstResponder];
        UIMenuController *popMenu = [UIMenuController sharedMenuController];
//        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"编辑" action:@selector(menuItem1Pressed)];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(menuItem2Pressed:)];
        NSArray *menuItems = [NSArray arrayWithObjects:item2,nil];
        [popMenu setMenuItems:menuItems];
        [popMenu setArrowDirection:UIMenuControllerArrowDown];
        [popMenu setTargetRect:sender.view.frame inView:_imagePreviews];
        [popMenu setMenuVisible:YES animated:YES];
    }
}
/**
 *  点击图片
 */
//-(void)clickimagePreviews:(UITapGestureRecognizer *)sender{
//    CGPoint point = [sender locationInView:sender.view];
//    [self addtagViewimageClickinit:point isAddTagView:NO];
//}
-(void)viewTagIsPositiveAndNegative:(BOOL)isPositiveAndNegative view:(YXLTagView *)view{
//    if(isPositiveAndNegative){
//        view.isPositiveAndNegative=NO;
////        [self positive:view];
//    }else{
//        view.isPositiveAndNegative=YES;
////        [self negative:view];
//    }
    
 
    
    NSLog(@"%ld",(long)viewTag.tag);
    
    if (viewTag.isAudio) {
        
        //播放
        [LGAudioPlayer sharePlayer].delegate = self;
        [[LGAudioPlayer sharePlayer] playAudioWithData:[[LGSoundRecorder shareInstance] convertAMRtoCAF:viewTag.audio_data] withTag:viewTag.tag];
        
    }
    
}
/**
 *  正向
 */
//-(void)positive:(YXLTagView *)view{
//    [view mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@(CGOriginX(view.frame)+CGWidth(view.frame)-8));
//        if (CGRectGetMaxX(view.frame)+CGWidth(view.frame)-8 >=kWindowWidth) {
//            make.left.equalTo(@(kWindowWidth-CGWidth(view.frame)));
//        }
//    }];
//}
/**
 *  反向
 */
//-(void)negative:(YXLTagView *)view{
//    [view mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@(CGOriginX(view.frame)-CGWidth(view.frame)+8));
//        if (CGOriginX(view.frame)-CGWidth(view.frame)+8<=0) {
//            make.left.equalTo(@0);
//        }
//    }];
//}
#pragma -mark
/**
 *  编辑
 */
//-(void)menuItem1Pressed{
//    MiYiTagSearchBarVC *vc =[[MiYiTagSearchBarVC alloc]init];
//    __weak YXLTagEditorImageView *ws =self;
//    vc.block=^(NSString *text){
//        viewTag.imageLabel.labelWaterFlow.text=text;
//        [viewTag mas_updateConstraints:^(MASConstraintMaker *make) {
//            CGSize size =[text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:Font(11),NSFontAttributeName, nil]];
//            CGFloat W;
//            if (CGWidth(imageLabelIcon)-15 > size.width) {
//                W=0;
//            }else{
//                W=size.width-(CGWidth(imageLabelIcon)-15);
//            }
//            if(viewTag.isPositiveAndNegative){
//                if (CGRectGetMaxX(viewTag.frame)-(CGWidth(imageLabelIcon)+8+W)<=0) {
//                    make.left.equalTo(@0);
//                }
//            }else{
//                if (CGRectGetMaxX(viewTag.frame) >=kWindowWidth) {
//                    make.left.equalTo(@(kWindowWidth-(CGWidth(imageLabelIcon)+8+W)));
//                }
//            }
//            [ws correct:text isPositiveAndNegative:YES];
//
//        }];
//    };
//    [self.viewC.navigationController pushViewController:vc animated:YES];
//}
/**
 *  删除
 */
-(void)menuItem2Pressed:(UIGestureRecognizer *)ges{
    

//    for (YXLTagView *tagView in arrayTagS) {
//        if ([tagView isEqual: viewTag]) {
//            [arrayTagS removeObject:tagView];
//            [tagView removeFromSuperview];
//            
//            break;
//        }
//    }
    

    for (myDrawShapeLayer *circleView in self.circleLayerArr) {
        if (circleView.tag == viewTag.tag) {
            
            [circleView removeFromSuperlayer];
            [arrayTagS removeObject:circleView];
            
            break;
        }
    }

    
    for (myDrawShapeLayer *line in self.lineLayerArr) {
        if (line.tag == viewTag.tag) {
            
            [line removeFromSuperlayer];
            [self.lineLayerArr removeObject:line];
            
            break;
        }
    }
    
    
    
    for (YXLTagView *tagView in arrayTagS) {
        if (tagView.tag == viewTag.tag) {
            [arrayTagS removeObject:tagView];
            [tagView removeFromSuperview];
            
            break;
        }
    }
    

}

/**
 *  pan手势  标签移动
 */
-(void)panTagViewPoint:(CGPoint )point withLineLayer:(myDrawShapeLayer *)lineLayer{
    
    
    CGFloat ViewtagX = point.x-viewTagLeft;
    CGFloat ViewtagY = point.y-imageLabelIcon.size.height/2;
    if((point.x-viewTagLeft)<=0){
        ViewtagX = 0;
    }
    if (point.y+imageLabelIcon.size.height/2 >=CGRectGetHeight(_imagePreviews.frame)) {
        ViewtagY = CGRectGetHeight(_imagePreviews.frame)-imageLabelIcon.size.height;
    }
    if (point.y-imageLabelIcon.size.height/2 <= 0) {
        ViewtagY = 0;
    }
    if (point.x+(CGWidth(viewTag.frame)-viewTagLeft) >=kWindowWidth) {
        ViewtagX = kWindowWidth-(CGWidth(viewTag.frame));
    }
    
    [viewTag mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(ViewtagX));
        make.top.equalTo(@(ViewtagY));
       
    }];
    
    
    
    CGPoint redIconPoint = CGPointMake(ViewtagX , ViewtagY + imageLabelIcon.size.height/2.0);

    
    //线 更新
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    [tPath moveToPoint:lineLayer.circlePoint];                              // r1点
    [tPath addLineToPoint:redIconPoint]; // r3,r4,r5确定的一个弧线
    lineLayer.path = tPath.CGPath;
    lineLayer.lineEndPoint = redIconPoint;
    
}


#pragma -mark 点击

-(void)clickViewMBP{
    [self mbpAnimation:NO];
}

-(void)clickButtonOne{
    
    NSLog(@"点击了 文字");

    
    myDrawShapeLayer *line = self.lineLayerArr.lastObject;
    [line setStrokeColor:self.textLineColor.CGColor];
    
    myDrawShapeLayer *circle = self.circleLayerArr.lastObject;
    [circle setStrokeColor:self.textLineColor.CGColor];
    

    __weak typeof(self) weakSelf = self;
    [[annotateAndCommentView shared] showViewWithSelectBlock:^(BOOL isSure, NSString *text) {
        
        
        if (isSure) {
            
            viewTag.isAudio = NO;
            viewTag.isImageLabelShow=YES;
            viewTag.imageLabel.labelWaterFlow.text= text;
            [weakSelf correct:text isPositiveAndNegative:YES];
            [weakSelf mbpAnimation:NO];
            
        }else{
            
            [weakSelf mbpAnimation:NO];
        }
        
    }];

    
}

-(void)clickButtonTwo{
    
    
    NSLog(@"点击了 语音");
    
    myDrawShapeLayer *line = self.lineLayerArr.lastObject;
    [line setStrokeColor:self.audioLineColor.CGColor];
    
    myDrawShapeLayer *circle = self.circleLayerArr.lastObject;
    [circle setStrokeColor:self.audioLineColor.CGColor];
    
    
    __weak typeof(self) weakSelf = self;

    [[recordView shared] showRecordViewWithBlock:^(BOOL isSure, NSData *data ,NSString *time) {
        
       
        if (isSure) {
            
            viewTag.isAudio = YES;
            viewTag.isImageLabelShow=YES;
            viewTag.imageLabel.labelWaterFlow.text=@"11s";
            [weakSelf correct:@"11s" isPositiveAndNegative:YES];
            [weakSelf mbpAnimation:NO];
            
            viewTag.audio_data = data;
            viewTag.audioViewLabel.labelTime.text = [NSString stringWithFormat:@"%@s",time];
            
            
        }else{
        
            [weakSelf mbpAnimation:NO];
            
        }
        
        [[recordView shared] removeFromSuperview];
        

        
    }];
    
}

/**
 *  修正
 */
-(void)correct:(NSString *)text isPositiveAndNegative:(BOOL)isPositiveAndNegative{
    CGSize size =[text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:Font(11),NSFontAttributeName, nil]];
    CGFloat W;
    if (CGWidth(imageLabelIcon)-15 > size.width) {
        W=0;
    }else{
        W=size.width-(CGWidth(imageLabelIcon)-15);
    }
    
    if (CGOriginX(viewTag.frame)+(CGWidth(imageLabelIcon)+8+W) >=kWindowWidth) {
        [viewTag mas_updateConstraints:^(MASConstraintMaker *make) {
            if (isPositiveAndNegative) {
                viewTag.isPositiveAndNegative=YES;
                make.left.equalTo(@(CGOriginX(viewTag.frame)-(CGWidth(imageLabelIcon)+8+W)));
            }else{
                make.left.equalTo(@(CGRectGetMaxX(viewTag.frame)-(CGWidth(imageLabelIcon)+8+W)));
                
            }
            
        }];
    }
}

#pragma -mark 初始化
-(UIImageView *)getimagePreviews{
    UIImageView *image =[UIImageView new];
    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickimagePreviews:)];
//    tap.numberOfTapsRequired=1;
//    tap.numberOfTouchesRequired=1;
//    tap.delegate = self;
//    [image addGestureRecognizer:tap];
    return image;
}

-(UIButton *)getButtonOne{
    UIButton *btn =[UIButton new];
    btn.backgroundColor=UIColorRGBA(0, 0, 0, 0.6);
    [btn setTitle:@"文字" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonOne) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(UIButton *)getButtonTwo{
    UIButton *btn =[UIButton new];
    btn.backgroundColor=UIColorRGBA(0, 0, 0, 0.6);
    [btn setTitle:@"语音" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickButtonTwo) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


#pragma -mark 尺寸
-(void)scaledFrame{
    CGRect noScale = CGRectMake(0.0, 0.0, _imagePreviews.image.size.width , _imagePreviews.image.size.height );
    if (CGWidth(noScale) <= kWindowWidth && CGHeight(noScale) <= self.frame.size.height) {
        imageScale = 1.0;
        [_imagePreviews mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(noScale.size);
        }];
        return ;
    }
    CGRect scaled;
    imageScale= (kWindowHeight-64) / _imagePreviews.image.size.height;
    scaled=CGRectMake(0.0, 0.0, _imagePreviews.image.size.width * imageScale , _imagePreviews.image.size.height * imageScale );
    if (CGWidth(scaled) <= kWindowWidth && CGHeight(scaled) <= (kWindowHeight-64)) {
        [_imagePreviews mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(scaled.size);
        }];
        return ;
    }
    imageScale = kWindowWidth / _imagePreviews.image.size.width;
    scaled = CGRectMake(0.0, 0.0, _imagePreviews.image.size.width * imageScale, _imagePreviews.image.size.height * imageScale);
    [_imagePreviews mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(scaled.size);
    }];
}

#pragma -mark pop返回标签尺寸和文本
-(NSMutableArray *)popTagModel{
    NSMutableArray *array =[NSMutableArray array];
//    NSString *positiveAndNegative;
//    NSString *point;
    if (viewCover.alpha==1) {
        if (arrayTagS.count !=0) {
            YXLTagView *tag =[arrayTagS lastObject];
            if (!tag.isImageLabelShow) {
                [tag removeFromSuperview];
                [arrayTagS removeLastObject];
                
                myDrawShapeLayer *Circle = self.circleLayerArr.lastObject;
                [Circle removeFromSuperlayer];
                [arrayTagS removeLastObject];
                
                myDrawShapeLayer *line = self.lineLayerArr.lastObject;
                [line removeFromSuperlayer];
                [self.lineLayerArr removeLastObject];
            }
        }
    }
    

    
    for (int i = 0 ; i < arrayTagS.count ; i ++) {
        
        YXLTagView *tag =  arrayTagS[i];
        myDrawShapeLayer *circleLyer = self.circleLayerArr[i];

        
        tagViewModel *model = [[tagViewModel alloc]init];
        model.positiveAndNegative = viewTag.isPositiveAndNegative;
        model.isAudio = viewTag.isAudio;
        model.viewTagPointX = CGOriginX(tag.frame)/imageScale;
        model.viewTagPointY = CGOriginY(tag.frame)/imageScale;
        
        model.CircleStarPointX = circleLyer.prePoint.x / imageScale;
        model.CircleStarPointY = circleLyer.prePoint.y / imageScale;
        
        model.CircleCenterPointX = circleLyer.circlePoint.x / imageScale;
        model.CircleCenterPointY = circleLyer.circlePoint.y / imageScale;

        
        [array addObject:model];
        
//        positiveAndNegative =@"0";
//        point =[NSString stringWithFormat:@"%f,%f",CGOriginX(tag.frame)/imageScale,CGOriginY(tag.frame)/imageScale];
//        if(tag.isPositiveAndNegative ==YES){
//            positiveAndNegative =@"1";
//            point =[NSString stringWithFormat:@"%f,%f",CGRectGetMaxX(tag.frame)/imageScale,CGOriginY(tag.frame)/imageScale];
//        }
//        NSDictionary *dic=@{@"positiveAndNegative":positiveAndNegative,@"point":point,@"text":tag.imageLabel.labelWaterFlow.text};
//        [array addObject:dic];
    }
    return array;
}





- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    
    CGPoint location = [paramSender locationInView:paramSender.view];
    
    
    if (paramSender.state == UIGestureRecognizerStateEnded || paramSender.state == UIGestureRecognizerStateFailed){
        
        if (!CGPointEqualToPoint(self.currentLayer.prePoint, location)) {
            
            [self.circleLayerArr addObject:self.currentLayer];
            
            NSLog(@"圆数组个数 %lu",(unsigned long)self.circleLayerArr.count);
            self.currentLayer.circlePoint = CGPointMake((self.currentLayer.prePoint.x + location.x)/2.0, (self.currentLayer.prePoint.y + location.y)/2.0);
            self.currentLayer.endPoint = location;
            NSLog(@"当前 中心点 %f %f" ,self.currentLayer.circlePoint.x,self.currentLayer.circlePoint.y);
            
            // 绘制 中心到 标签 连线
            myDrawShapeLayer *lineLayer = [self setLineFromCirclePoint:self.currentLayer.circlePoint
                                                               toPoint:CGPointMake((self.currentLayer.circlePoint.x +  MIN(self.currentLayer.prePoint.x, self.currentLayer.endPoint.x)  ) / 2.0, MIN(self.currentLayer.prePoint.y, self.currentLayer.endPoint.y) - 10  )
                                                             WithColor:self.lineColor
                                                              WithView:self];
            lineLayer.tag = self.currentLayer.tag;
            lineLayer.circlePoint = self.currentLayer.circlePoint;
            lineLayer.lineEndPoint = CGPointMake((self.currentLayer.circlePoint.x +  MIN(self.currentLayer.prePoint.x, self.currentLayer.endPoint.x)  ) / 2.0, MIN(self.currentLayer.prePoint.y, self.currentLayer.endPoint.y) - 10  );
            [_imagePreviews.layer addSublayer:lineLayer];
            
            [self.lineLayerArr addObject:lineLayer];
            
            
            //标签
//            CGPoint point = [sender locationInView:sender.view];
            [self addtagViewimageClickinit:lineLayer.lineEndPoint isAddTagView:NO];
            
        }
        
        return;
    }
    
    
    
    
    //cx和cy是手指的偏移量，用他们可以计算出新的location
    //    float cx = point.x - self.prePoint.x;
    //    float cy = point.y - self.prePoint.y;
    
    CGRect newRect = CGRectMake(MIN(self.currentLayer.prePoint.x, location.x),  MIN(self.currentLayer.prePoint.y, location.y),fabs(self.currentLayer.prePoint.x - location.x) , fabs(self.currentLayer.prePoint.y - location.y));
    //用新的location绘制一遍
    NSLog(@"%@" , [NSString stringWithFormat:@"%f , %f" ,self.currentLayer.prePoint.y ,location.y]);
    
    
    [self drawBallLayerWithRect:newRect WithColor:self.lineColor WithLayer:self.currentLayer];
    
    
}



#pragma mark - ---------------          ------------------

#pragma mark - 手势代理
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    
    //更新tag
    self.tagNum += 1;
    
    //手指在屏幕上的点的信息
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_imagePreviews];
    
    
    
    [self setCircleShapeLayerWithPrePoint:point circlePoint:point WithColor:self.lineColor];
    
//    [shapeLayer setBounds:self.bounds];
//    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)/2.0)];
//    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
//    //  设置虚线颜色为blackColor
//    [shapeLayer setStrokeColor:self.lineColor.CGColor];
//    //  设置虚线宽度
//    [shapeLayer setLineWidth:1];
//    //  设置路径
//    
//    // 更新_shapeLayer形状
//    //    CGPathRelease(tPath.CGPath);
//    
//    shapeLayer.lineWidth = 1;
//    
//    self.currentLayer = shapeLayer;
//    
//    [_imagePreviews.layer addSublayer:self.currentLayer];
//    
//    
//    NSLog(@"x=%f,y=%f",point.x,point.y);
}



- (myDrawShapeLayer *)setLineFromCirclePoint:(CGPoint)centerPoint toPoint:(CGPoint)point WithColor:(UIColor *)color WithView:(UIView *)view{
    
    
    myDrawShapeLayer *shapeLayer = [myDrawShapeLayer layer];
    
    shapeLayer.circlePoint = centerPoint;
    shapeLayer.lineEndPoint = point;
    
    [shapeLayer setBounds:view.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(view.frame) / 2, CGRectGetHeight(view.frame)/2.0)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:color.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:2], nil]];
    //  设置路径
    
    // 更新_shapeLayer形状
    //    CGPathRelease(tPath.CGPath);
    
    shapeLayer.lineWidth = 1;
    
    
    UIBezierPath *tPath = [UIBezierPath bezierPath];
    [tPath moveToPoint:centerPoint];                              // r1点
    [tPath addLineToPoint:point]; // r3,r4,r5确定的一个弧线
    
    
    shapeLayer.path = tPath.CGPath;
    
    return shapeLayer;
    
}


- (void)setCircleShapeLayerWithPrePoint:(CGPoint)prePoint circlePoint:(CGPoint)circlePoint WithColor:(UIColor *)color{

    
//    myDrawShapeLayer *shapeLayer = [[myDrawShapeLayer alloc]init];
//    shapeLayer.tag = self.tagNum;
//    
    myDrawShapeLayer *shapeLayer = [[myDrawShapeLayer alloc]init];
    shapeLayer.tag = self.tagNum;
    
    shapeLayer.prePoint = prePoint;
    shapeLayer.circlePoint = circlePoint;
    
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)/2.0)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setLineWidth:1];
    //  设置路径
    
    // 更新_shapeLayer形状
    //    CGPathRelease(tPath.CGPath);
    
    
    CGRect newRect = CGRectMake(MIN(prePoint.x, circlePoint.x * 2 - prePoint.x),  MIN(prePoint.y, circlePoint.y * 2 - prePoint.y),fabs(circlePoint.x - prePoint.x) * 2 , fabs(circlePoint.y - prePoint.y) * 2);
    
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithOvalInRect:newRect];
    shapeLayer.path = ovalPath.CGPath;
    shapeLayer.lineWidth = 1;
    
    self.currentLayer = shapeLayer;
    
    [_imagePreviews.layer addSublayer:self.currentLayer];
    
    
}


- (CALayer *)drawBallLayerWithRect:(CGRect )rect WithColor:(UIColor *)color WithLayer:(CAShapeLayer *)shapeLayer{
    
    
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithOvalInRect:rect];
    shapeLayer.path = ovalPath.CGPath;
    
    
    return shapeLayer;
    
}


#pragma mark - LGAudioPlayerDelegate

- (void)audioPlayerStateDidChanged:(LGAudioPlayerState)audioPlayerState forIndex:(NSUInteger)index {

    
    NSLog(@"播放状态 %lu",(unsigned long)audioPlayerState);

    
    
    LGVoicePlayState voicePlayState;
    switch (audioPlayerState) {
        case LGAudioPlayerStateNormal:
            voicePlayState = LGVoicePlayStateNormal;
            break;
        case LGAudioPlayerStatePlaying:
            voicePlayState = LGVoicePlayStatePlaying;
            break;
        case LGAudioPlayerStateCancel:
            voicePlayState = LGVoicePlayStateCancel;
            break;
            
        default:
            break;
    }
    
    
    

        for (YXLTagView *tagVeiw in arrayTagS) {
            
            if (tagVeiw.tag == index) {
                
                
                tagVeiw.audioViewLabel.voicePlayState = voicePlayState;
                break;

            }
            
            
        }
    
}





#pragma mark -
- (NSMutableArray *)circleLayerArr{
    
    if (!_circleLayerArr) {
        
        _circleLayerArr = [NSMutableArray array];
    }
    return _circleLayerArr;
}

- (NSMutableArray *)lineLayerArr{
    
    if (!_lineLayerArr) {
        
        _lineLayerArr = [NSMutableArray array];
    }
    return _lineLayerArr;
}




@end
