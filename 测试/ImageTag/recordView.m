//
//  recordView.m
//  测试
//
//  Created by apple on 2017/6/19.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import "recordView.h"
#import "Masonry.h"

#import "LGAudioKit.h"


#define SOUND_RECORD_LIMIT 60
#define DocumentPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface recordView ()

@property (nonatomic, weak) NSTimer *timerOf60Second;


@property (nonatomic ,assign) int audioTime;

@end

@implementation recordView


+ (recordView *)shared
{
    static recordView *shared = nil;
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



- (void)showRecordViewWithBlock:(completeBlock)block{

    
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
    
    self.block = block;

}


- (void)setUI{

    
    self.backgroundColor = [UIColor orangeColor];
    
    
    [[LGSoundRecorder shareInstance] initHUBViewWithView:self];
    
    
    UIButton *btn1 = [[UIButton alloc]init];
    [btn1 setTitle:@"结束" forState:UIControlStateNormal];
    [btn1 setTitleColor:self.tintColor forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn1];
    
    
    UIButton *btn2 = [[UIButton alloc]init];
    [btn2 setTitle:@"开始" forState:UIControlStateNormal];
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



#pragma mark - Private Methods

/**
 *  开始录音
 */
- (void)startRecordVoice{
    __block BOOL isAllow = 0;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                isAllow = 1;
            } else {
                isAllow = 0;
            }
        }];
    }
    if (isAllow) {
        //		//停止播放
        [[LGAudioPlayer sharePlayer] stopAudioPlayer];
        //		//开始录音
        NSLog(@"%@",[self recordPath]);
        [[LGSoundRecorder shareInstance] startSoundRecordPath:[self recordPath]];
//        [[LGSoundRecorder shareInstance] startSoundRecord:self recordPath:[self recordPath]];
        //开启定时器
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        _timerOf60Second = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sixtyTimeStopAndSendVedio) userInfo:nil repeats:YES];
    } else {
        
    }
}

/**
 *  录音结束
 */
- (void)confirmRecordVoice {
    if ([[LGSoundRecorder shareInstance] soundRecordTime] == 0) {
        [self cancelRecordVoice];
        return;//60s自动发送后，松开手走这里
    }
    if ([[LGSoundRecorder shareInstance] soundRecordTime] < 1.0f) {
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;
        }
        [self showShotTimeSign];
        return;
    }
    
//    [self sendSound];
    [[LGSoundRecorder shareInstance] stopSoundRecord:self];
    
    if (_timerOf60Second) {
        [_timerOf60Second invalidate];
        _timerOf60Second = nil;
    }
    
    //转 .amr
//    __weak typeof (self) weakSelf = self;
//    [[LGSoundRecorder shareInstance] CAFChangeToMP3:[self recordPath] withBlock:^(NSData *data) {
//        
//        weakSelf.block(YES  , data , [NSString stringWithFormat:@"%d",self.audioTime]);
//        
//    }];
    
    
    NSData *data = [[LGSoundRecorder shareInstance] convertCAFtoAMR]; //[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[LGSoundRecorder shareInstance].recordPath]];//
    
    self.block(YES  , data , [NSString stringWithFormat:@"%d",self.audioTime]);
    
    
    //删除录音
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL res=[manager removeItemAtPath:[LGSoundRecorder shareInstance].recordPath error:nil];
    if (res) {
        NSLog(@"文件删除成功");
    }else
        NSLog(@"文件删除失败");
    NSLog(@"文件是否存在: %@",[manager isExecutableFileAtPath:[LGSoundRecorder shareInstance].recordPath]?@"YES":@"NO");
}



/**
 *  取消录音
 */
- (void)cancelRecordVoice {
    [[LGSoundRecorder shareInstance] soundRecordFailed:self];
}

/**
 *  录音时间短
 */
- (void)showShotTimeSign {
    [[LGSoundRecorder shareInstance] showShotTimeSign:self];
}

- (void)sixtyTimeStopAndSendVedio {
    int countDown = SOUND_RECORD_LIMIT - [[LGSoundRecorder shareInstance] soundRecordTime];
    NSLog(@"countDown is %d soundRecordTime is %f",countDown,[[LGSoundRecorder shareInstance] soundRecordTime]);
//    if (countDown <= 10) {
        [[LGSoundRecorder shareInstance] showCountdown:countDown];
    
        self.audioTime = [[LGSoundRecorder shareInstance] soundRecordTime];
    
//    }
    if ([[LGSoundRecorder shareInstance] soundRecordTime] >= SOUND_RECORD_LIMIT && [[LGSoundRecorder shareInstance] soundRecordTime] <= SOUND_RECORD_LIMIT + 1) {
        
        if (_timerOf60Second) {
            [_timerOf60Second invalidate];
            _timerOf60Second = nil;

            self.audioTime = 0;
        }
//        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


/**
 *  语音文件存储路径
 *
 *  @return 路径
 */
- (NSString *)recordPath {
    NSString *filePath = [DocumentPath stringByAppendingPathComponent:@"SoundFile"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    return filePath;
}



- (void)cancelBtnClick{
    
//    self.block(NO, nil , @"11");
//    
//    [self removeFromSuperview];
    

    [self confirmRecordVoice];
    
}

- (void)sureBtnClick{
    
//    self.block(YES , nil , @"11");
    
    
    [self startRecordVoice];
    
//    [self removeFromSuperview];
    
    
}



@end
