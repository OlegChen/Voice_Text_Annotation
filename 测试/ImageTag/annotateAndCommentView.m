//
//  annotateAndCommentView.m
//  测试
//
//  Created by apple on 2017/6/19.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import "annotateAndCommentView.h"
#import "Masonry.h"

@interface annotateAndCommentView ()<UITableViewDelegate ,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic ,strong) UITextField *textField;

@property (nonatomic ,strong) NSMutableArray *annotateArray;

@property (nonatomic ,copy) NSString *plistPath;

@end

@implementation annotateAndCommentView


+ (annotateAndCommentView *)shared
{
    static annotateAndCommentView *shared = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shared = [[self alloc] init];
    });
    return shared;
}


- (instancetype)init{

    self = [super init];
    
    if (self) {
        
        [self setUI];
        
    }
    
    return self;

}


- (void)showViewWithSelectBlock:(selectBlock)block
{

    self.textField.text = @"";
    
    //数据
    self.annotateArray = [NSMutableArray arrayWithContentsOfFile:self.plistPath];
    [self.tableView reloadData];
    
    //显示
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(window).offset(0);
        make.centerY.equalTo(window).offset(0);
        
        make.left.equalTo(window).offset(30);
        make.right.equalTo(window).offset(-30);
        
        make.height.mas_equalTo(300);

    }];
    
    
    //
    self.block = block;
}

- (void)setUI{
    
    
    self.backgroundColor = [UIColor whiteColor];

    _textField = [UITextField new];
    _textField.backgroundColor = [UIColor orangeColor];
    [_textField setFont:[UIFont systemFontOfSize:17]];
    [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textField];
    _textField.returnKeyType = UIReturnKeyDone;
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10 );
        make.top.equalTo(self);
        make.height.mas_equalTo(40);
        
    }];

    
    

    _tableView = [[UITableView alloc]init];
    [self addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(40, 0, 40 , 0));
        
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    UIButton *btn1 = [[UIButton alloc]init];
    [btn1 setTitle:@"取消" forState:UIControlStateNormal];
    [btn1 setTitleColor:self.tintColor forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn1];
    
    
    
    UIButton *btn2 = [[UIButton alloc]init];
    [btn2 setTitle:@"确定" forState:UIControlStateNormal];
    [btn2 setTitleColor:self.tintColor forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn2];
    
    btn2.backgroundColor = [UIColor redColor];
    
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(self);
        make.height.equalTo(@40);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.and.width.and.height.equalTo(btn1);
        make.left.equalTo(btn1.mas_right);
        make.right.equalTo(self);
        
    }];
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.annotateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    }
    NSDictionary *dic = self.annotateArray[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"key"];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //block(self.textField.text.length , self.textField.text);

    
    [self removeFromSuperview];

}

- (void)textValueChanged:(UITextField *)textFild{
    
    //判断
//    [CustomerManager limtitLength:textFild WithLenght:self.StrLength];
//    
//    if (self.textValueChange) {
//        
//        self.textValueChange(textFild.text);
//    }
}

- (void)cancelBtnClick{

    self.block(NO, nil);
    
    [self removeFromSuperview];

    
}

- (void)sureBtnClick{

    if (self.textField.text.length > 0  ) {
        
        NSDictionary *dic = @{@"key" : self.textField.text};
        [self.annotateArray insertObject:dic atIndex:0];
        if (self.annotateArray.count > 10) {
            
            [self.annotateArray removeLastObject];
        }
        [self.annotateArray writeToFile:self.plistPath atomically:YES];
        
        self.block(YES, self.textField.text);
        
        
#warning ---  记录到本地

        
    }else{
    
#warning  ---------- 
        
        NSLog(@"长度不够");
        
    }
    
    [self removeFromSuperview];
    
    
}

- (NSMutableArray *)annotateArray{

    if (!_annotateArray) {
        
        _annotateArray = [NSMutableArray array];
        
    }
    return _annotateArray;
}


- (NSString *)plistPath{

    if (!_plistPath) {
        
        
        //读取数据
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        _plistPath = [documentsDirectory stringByAppendingPathComponent:@"annotate.plist"];
        NSLog(@"_plistPath  %@",_plistPath);
    }
    return _plistPath;
}

@end
