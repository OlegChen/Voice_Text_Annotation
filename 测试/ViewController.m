//
//  ViewController.m
//  测试
//
//  Created by apple on 2017/5/5.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import "ViewController.h"


#import "myDrawShapeLayer.h"


#import "YXLTagEditorImageView.h"

#import "tagViewModel.h"


@interface ViewController ()<UIGestureRecognizerDelegate>
{
    YXLTagEditorImageView *tagEditorImageView;
}

//@property (nonatomic ,strong)NSMutableArray *arr;
//
//@property (weak, nonatomic) IBOutlet UIView *VIEW;




@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view .backgroundColor =HEX_COLOR_VIEW_BACKGROUND;
    
    tagEditorImageView =[[YXLTagEditorImageView alloc]initWithImage:[UIImage imageNamed:@"timg.jpeg"]];
    tagEditorImageView.backgroundColor = [UIColor grayColor];
    tagEditorImageView.viewC=self;
    tagEditorImageView.userInteractionEnabled=YES;
    [self.view addSubview:tagEditorImageView];
    [tagEditorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    tagViewModel *model = [[tagViewModel alloc]init];
    model.isAudio = YES;
    model.audioTime = @"11s";
    model.viewTagPointX = 40;
    model.viewTagPointY = 40;
    model.CircleStarPointX = 60;
    model.CircleStarPointY = 60;
    model.CircleCenterPointX = 100;
    model.CircleCenterPointY = 100;
    
    model.text = @"就是假按揭房；拿了份";
    
    [tagEditorImageView addTagViewWithModel:model];
    
//    [tagEditorImageView addTagViewText:@"哈哈哈哈" Location:CGPointMake(448.309179,296.296296) isPositiveAndNegative:YES];
//    
//    [tagEditorImageView addTagViewText:@"哈哈lalallallal" Location:CGPointMake(430.917874, 295.652174) isPositiveAndNegative:NO];
    
    
    UIBarButtonItem *item =[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(navItemClick)];
    self.navigationItem.rightBarButtonItem=item;
    
}
//
/////**
//// *  确定并pop    返回这个图片所有的标签地址内容，是否翻转样式的数组   坐标为这个图片的真实坐标
//// */
//-(void)navItemClick{
//    
//    NSMutableArray *array =[tagEditorImageView popTagModel];
//    if (array.count==0) {
//        [self.navigationController popViewControllerAnimated:YES];
//        return;
//    }
//    NSMutableArray *array1 =[NSMutableArray array];
//    for(NSDictionary *dic in array){
//        BOOL is =[dic[@"positiveAndNegative"] boolValue];
//        NSString *positiveAndNegative ;
//        if (is) {
//            positiveAndNegative=@"反";
//        }else{
//            positiveAndNegative=@"正";
//        }
//        NSString *string =[NSString stringWithFormat:@"方向%@坐标%@文本%@",positiveAndNegative,dic[@"point"],dic[@"text"]];
//        [array1 addObject:string];
//    }
//    NSString *string =[array1 componentsJoinedByString:@"\n"];
//    _popBlock(string);
//    [self.navigationController popViewControllerAnimated:YES];
//}

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tagNum = 100;
    
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePanGestures:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.delaysTouchesEnded = NO;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    
   
    
}


- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    
    CGPoint location = [paramSender locationInView:paramSender.view.superview];

    
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
                                                                     WithColor:[UIColor blackColor]
                                                                      WithView:self.view];
                    lineLayer.tag = self.currentLayer.tag;
                    [self.view.layer addSublayer:lineLayer];
                    
                    [self.lineLayerArr addObject:lineLayer];
                
                }
                
                return;
            }
    
    
    
    
    //cx和cy是手指的偏移量，用他们可以计算出新的location
    //    float cx = point.x - self.prePoint.x;
    //    float cy = point.y - self.prePoint.y;
    
    CGRect newRect = CGRectMake(MIN(self.currentLayer.prePoint.x, location.x),  MIN(self.currentLayer.prePoint.y, location.y),fabs(self.currentLayer.prePoint.x - location.x) , fabs(self.currentLayer.prePoint.y - location.y));
    //用新的location绘制一遍
    NSLog(@"%@" , [NSString stringWithFormat:@"%f , %f" ,self.currentLayer.prePoint.y ,location.y]);
    
    
    [self drawBallLayerWithRect:newRect WithColor:[UIColor blackColor] WithLayer:self.currentLayer];
    
    
}


#pragma mark - 手势代理
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    
    //更新tag
    self.tagNum += 1;
    
    //手指在屏幕上的点的信息
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    
    myDrawShapeLayer *shapeLayer = [[myDrawShapeLayer alloc]init];
    shapeLayer.tag = self.tagNum;
    
    shapeLayer.prePoint = point;

    
    [shapeLayer setBounds:self.view.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame)/2.0)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:[UIColor blackColor].CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:1];
    //  设置路径
    
    // 更新_shapeLayer形状
    //    CGPathRelease(tPath.CGPath);
    
    shapeLayer.lineWidth = 1;
    
    self.currentLayer = shapeLayer;
    
    [self.view.layer addSublayer:self.currentLayer];
    
    
    NSLog(@"x=%f,y=%f",point.x,point.y);
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




- (CALayer *)drawBallLayerWithRect:(CGRect )rect WithColor:(UIColor *)color WithLayer:(CAShapeLayer *)shapeLayer{
    
    
    
    UIBezierPath *ovalPath=[UIBezierPath bezierPathWithOvalInRect:rect];
    shapeLayer.path = ovalPath.CGPath;
    
    
    return shapeLayer;
    
}


//- (UIBezierPath *)getWXPathWithStar:(CGPoint)start Withcontol:(CGPoint)control WithEnd:(CGPoint)end{
//    
//    UIBezierPath *tPath = [UIBezierPath bezierPath];
//    [tPath moveToPoint:CGPointMake(start.x , start.y)];                              // r1点
//    [tPath addQuadCurveToPoint:CGPointMake(end.x, end.y)  //左上
//                  controlPoint:CGPointMake(control.x, control.y)]; // r3,r4,r5确定的一个弧线
//    
//    return tPath;
//    
//}


#pragma mark - 手势


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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
 */


@end
