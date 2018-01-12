//
//  LGSoundRecorder.m
//  下载地址：https://github.com/gang544043963/LGAudioKit
//
//  Created by ligang on 16/8/20.
//  Copyright © 2016年 LG. All rights reserved.
//

#import "LGSoundRecorder.h"
#import "MBProgressHUD.h"
#include "amrFileCodec.h"

#import "Masonry.h"

#import <lame/lame.h>


#pragma clang diagnostic ignored "-Wdeprecated"

#define GetImage(imageName)  [UIImage imageNamed:imageName]

@interface LGSoundRecorder()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
//Views
@property (nonatomic, strong) UIImageView *imageViewAnimation;
@property (nonatomic, strong) UIImageView *talkPhone;
@property (nonatomic, strong) UIImageView *cancelTalk;
@property (nonatomic, strong) UIImageView *shotTime;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UILabel *countDownLabel;

@end

@implementation LGSoundRecorder


+ (LGSoundRecorder *)shareInstance {
	static LGSoundRecorder *sharedInstance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		if (sharedInstance == nil) {
			sharedInstance = [[LGSoundRecorder alloc] init];
		}
	});
	return sharedInstance;
}

#pragma mark - Public Methods

- (void)startSoundRecordPath:(NSString *)path {
	self.recordPath = path;
//	[self initHUBViewWithView:view];
	[self startRecord];
}

- (void)stopSoundRecord:(UIView *)view {
	if (self.levelTimer) {
		[self.levelTimer invalidate];
		self.levelTimer = nil;
	}
	
	NSString *str = [NSString stringWithFormat:@"%f",_recorder.currentTime];
	
	int times = [str intValue];
	if (self.recorder) {
		[self.recorder stop];
	}
	if (times >= 1) {
		if (view == nil) {
			view = [[[UIApplication sharedApplication] windows] lastObject];
		}
		
		if ([view isKindOfClass:[UIWindow class]]) {
			[view addSubview:_HUD];
		} else {
			[view.window addSubview:_HUD];
		}
		if (_delegate&&[_delegate respondsToSelector:@selector(didStopSoundRecord)]) {
			[_delegate didStopSoundRecord];
		}
	} else {
		[self deleteRecord];
		[self.recorder stop];
		if ([_delegate respondsToSelector:@selector(showSoundRecordFailed)]) {
			[_delegate showSoundRecordFailed];
		}
	}
	[self removeHUD];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
	//恢复外部正在播放的音乐
	[[AVAudioSession sharedInstance] setActive:NO
									 withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
										 error:nil];
}

- (void)soundRecordFailed:(UIView *)view {
	[self.recorder stop];
	[self removeHUD];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
	//恢复外部正在播放的音乐
	[[AVAudioSession sharedInstance] setActive:NO
									 withFlags:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
										 error:nil];
}

- (void)readyCancelSound {
	_imageViewAnimation.hidden = YES;
	_talkPhone.hidden = YES;
	_cancelTalk.hidden = NO;
	_shotTime.hidden = YES;
	_countDownLabel.hidden = YES;
	
	_textLable.frame = CGRectMake(0, CGRectGetMaxY(_imageViewAnimation.frame) + 20, 130, 25);
	_textLable.text = @"手指松开，取消发送";
	_textLable.backgroundColor = [UIColor redColor];
	_textLable.layer.masksToBounds = YES;
	_textLable.layer.cornerRadius = 3;
}

- (void)resetNormalRecord {
	_imageViewAnimation.hidden = NO;
	_talkPhone.hidden = NO;
	_cancelTalk.hidden = YES;
	_shotTime.hidden = YES;
	_countDownLabel.hidden = YES;
	_textLable.frame = CGRectMake(0, CGRectGetMaxY(_imageViewAnimation.frame) + 20, 130, 25);
	_textLable.text = @"手指上滑，取消发送";
	_textLable.backgroundColor = [UIColor clearColor];
}

- (void)showShotTimeSign:(UIView *)view {
	_imageViewAnimation.hidden = YES;
	_talkPhone.hidden = YES;
	_cancelTalk.hidden = YES;
	_shotTime.hidden = NO;
	_countDownLabel.hidden = YES;
	[_textLable setFrame:CGRectMake(0, 100, 130, 25)];
	_textLable.text = @"说话时间太短";
	_textLable.backgroundColor = [UIColor clearColor];
	
	[self performSelector:@selector(stopSoundRecord:) withObject:view afterDelay:1.5f];
}

- (void)showCountdown:(int)countDown{
	_textLable.text = [NSString stringWithFormat:@"还可以说%d秒",countDown];
}

- (NSTimeInterval)soundRecordTime {
	return _recorder.currentTime;
}

#pragma mark - Private Methods

- (void)initHUBViewWithView:(UIView *)view {
//	if (_HUD) {
//		[_HUD removeFromSuperview];
//		_HUD = nil;
//	}
	if (view == nil) {
		view = [[[UIApplication sharedApplication] windows] lastObject];
	}
//	if (_HUD == nil) {
//		_HUD = [[MBProgressHUD alloc] initWithView:view];
//		_HUD.opacity = 0.4;
		
		CGFloat left = 22;
		CGFloat top = 0;
		top = 18;
		
		UIView *cv = [[UIView alloc] init];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 37, 70)];
		_talkPhone = imageView;
		_talkPhone.image = GetImage(@"toast_microphone");
		[cv addSubview:_talkPhone];
		left += CGRectGetWidth(_talkPhone.frame) + 16;
		
		top+=7;
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 29, 64)];
		_imageViewAnimation = imageView;
		[cv addSubview:_imageViewAnimation];
		
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 24, 52, 61)];
		_cancelTalk = imageView;
		_cancelTalk.image = GetImage(@"toast_cancelsend");
		[cv addSubview:_cancelTalk];
		_cancelTalk.hidden = YES;
		
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(56, 24, 18, 60)];
		self.shotTime = imageView;
		_shotTime.image = GetImage(@"toast_timeshort");
		[cv addSubview:_shotTime];
		_shotTime.hidden = YES;
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 70, 71)];
		self.countDownLabel = label;
		self.countDownLabel.backgroundColor = [UIColor clearColor];
		self.countDownLabel.textColor = [UIColor whiteColor];
		self.countDownLabel.textAlignment = NSTextAlignmentCenter;
		self.countDownLabel.font = [UIFont systemFontOfSize:60.0];
		[cv addSubview:self.countDownLabel];
		self.countDownLabel.hidden = YES;
		
		left = 0;
		top += CGRectGetHeight(_imageViewAnimation.frame) + 20;
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 130, 14)];
		self.textLable = label;
		_textLable.backgroundColor = [UIColor clearColor];
		_textLable.textColor = [UIColor whiteColor];
		_textLable.textAlignment = NSTextAlignmentCenter;
		_textLable.font = [UIFont systemFontOfSize:14.0];
		_textLable.text = @"还可以说60秒";
		[cv addSubview:_textLable];
		
    
    [view addSubview:cv];
    [cv mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake( 130, 120));
        make.centerX.equalTo(view).offset(0);
        make.centerY.equalTo(view).offset(0);
    }];
    
//		_HUD.customView = cv;
//		
//		// Set custom view mode
//		_HUD.mode = MBProgressHUDModeCustomView;
//	}
//	if ([view isKindOfClass:[UIWindow class]]) {
//		[view addSubview:_HUD];
//	} else {
//		[view.window addSubview:_HUD];
//	}
//	[_HUD show:YES];
}

- (void)removeHUD {
	if (_HUD) {
		[_HUD removeFromSuperview];
		_HUD = nil;
	}
}

- (void)startRecord {
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
	//设置AVAudioSession
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
	if(err) {
		[self soundRecordFailed:nil];
		return;
	}
	
	//设置录音输入源
	UInt32 doChangeDefaultRoute = 1;
	AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
	[audioSession setActive:YES error:&err];
	if(err) {
		[self soundRecordFailed:nil];
		return;
	}
	//设置文件保存路径和名称
	NSString *fileName = [NSString stringWithFormat:@"/voice-%5.2f.caf", [[NSDate date] timeIntervalSince1970] ];
	self.recordPath = [self.recordPath stringByAppendingPathComponent:fileName];
	NSURL *recordedFile = [NSURL fileURLWithPath:self.recordPath];
	NSDictionary *dic = [self recordingSettings];
	//初始化AVAudioRecorder
	err = nil;
	_recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:dic error:&err];
	if(_recorder == nil) {
		[self soundRecordFailed:nil];
		return;
	}
	//准备和开始录音
	[_recorder prepareToRecord];
	self.recorder.meteringEnabled = YES;
	[self.recorder record];
	[_recorder recordForDuration:0];
	if (self.levelTimer) {
		[self.levelTimer invalidate];
		self.levelTimer = nil;
	}
	self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0001 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (void)deleteRecord {
	if (self.recorder) {
		[self.recorder stop];
		[self.recorder deleteRecording];
	}
	
	if (self.HUD) {
		[self.HUD hide:NO];
	}
}

- (void)levelTimerCallback:(NSTimer *)timer {
	if (_recorder&&_imageViewAnimation) {
		[_recorder updateMeters];
		double ff = [_recorder averagePowerForChannel:0];
		ff = ff+60;
		if (ff>0&&ff<=10) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_0")];
		} else if (ff>10 && ff<20) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_1")];
		} else if (ff >=20 &&ff<30) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_2")];
		} else if (ff >=30 &&ff<40) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_3")];
		} else if (ff >=40 &&ff<50) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_4")];
		} else if (ff >= 50 && ff < 60) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_5")];
		} else if (ff >= 60 && ff < 70) {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_6")];
		} else {
			[_imageViewAnimation setImage:GetImage(@"toast_vol_7")];
		}
	}
}

#pragma mark - Getters

- (NSDictionary *)recordingSettings
{
	NSMutableDictionary *recordSetting =[NSMutableDictionary dictionaryWithCapacity:10];
	[recordSetting setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
	//2 采样率
	[recordSetting setObject:[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];
	//3 通道的数目
	[recordSetting setObject:[NSNumber numberWithInt:1]forKey:AVNumberOfChannelsKey];
	//4 采样位数  默认 16
	[recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	return recordSetting;
}

- (NSString *)soundFilePath {
	return self.recordPath;
}

#pragma mark - amr转换方法

- (NSData *)convertCAFtoAMR{
	NSData *data = [NSData dataWithContentsOfFile:self.recordPath];
	data = EncodeWAVEToAMR(data,1,16);
    
    
    
    
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [paths objectAtIndex:0];
//    NSLog(@"%@",[NSString stringWithFormat:@"%@/aaaaaa.amr",documentPath]);
////    NSString *amrName = [[[tempFile0 lastPathComponent] componentsSeparatedByString:@"."] firstObject];
//    [data writeToFile:[NSString stringWithFormat:@"%@/aaaaaa.amr",documentPath] atomically:YES];
//    
//    
    
    
    
    
	return data;
}


- (NSData *)convertAMRtoCAF:(NSData *)armData{

    
    armData = DecodeAMRToWAVE(armData); //EncodeWAVEToAMR(data,1,16);
    
    return armData;
}





#pragma mark - - caf 转换 mp3
- (void)CAFChangeToMP3:(NSString *)filePath withBlock:(mp3Complte)block{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *mp3FilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",[self getTimeStampFromOriginalTime:[NSDate date]]]];
        
        @try {
            int read, write;
            
            FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, 11025.0);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            NSLog(@"MP3生成成功: %@", mp3FilePath);
            
            NSData *data = [NSData dataWithContentsOfFile:mp3FilePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                block(data);
                
            });
            
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:CAFChangeToMP3Complete object:nil];
        }
        
    });
    
}



- (NSString *)getTimeStampFromOriginalTime:(NSDate *)originalDate {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hant"];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS Z";
    NSString *date = [fmt stringFromDate:originalDate];
    NSString *timeStamp = [NSString stringWithFormat:@"%f",[[fmt dateFromString:date] timeIntervalSince1970]* 1000];
    NSRange range = [timeStamp rangeOfString:@"."];
    return [timeStamp substringToIndex:range.location];
    
}


@end

