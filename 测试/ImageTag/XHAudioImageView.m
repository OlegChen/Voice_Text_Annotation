//
//  XHAudioImageView.m
//  测试
//
//  Created by Chen on 2017/6/18.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import "XHAudioImageView.h"
#import "pch.h"


@implementation XHAudioImageView

-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds=YES;
        
        
        [self addSubview:self.messageVoiceStatusImageView];
        [self.messageVoiceStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self).offset(0);
            make.left.equalTo(self).offset(10);
            
            make.size.mas_equalTo(CGSizeMake(15, 15));

        }];
        
        
        _labelTime =[[UILabel alloc]init];
        _labelTime.font =Font(11);
        _labelTime.text = @"00s";
        _labelTime.textColor=[UIColor whiteColor];
        _labelTime.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_labelTime];
        [_labelTime mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 10, 0, 5));
            
            make.top.equalTo(self).offset(0);
            make.right.equalTo(self).offset(-5);
            make.bottom.equalTo(self).offset(0);
        }];
    }
    return self;
}

#pragma mark - Setters

- (void)setVoicePlayState:(LGVoicePlayState)voicePlayState {
    
    
    if (_voicePlayState != voicePlayState) {
        _voicePlayState = voicePlayState;
    }

    self.messageVoiceStatusImageView.hidden = NO;
    
    if (_voicePlayState == LGVoicePlayStatePlaying) {
        self.messageVoiceStatusImageView.highlighted = YES;
        [self.messageVoiceStatusImageView startAnimating];
    }else if (_voicePlayState == LGVoicePlayStateDownloading) {

        self.messageVoiceStatusImageView.hidden = YES;
    }else {
        self.messageVoiceStatusImageView.highlighted = NO;
        [self.messageVoiceStatusImageView stopAnimating];
    }
}



- (UIImageView *)messageVoiceStatusImageView {
    if (!_messageVoiceStatusImageView) {
        _messageVoiceStatusImageView = [[UIImageView alloc] init];
        _messageVoiceStatusImageView.userInteractionEnabled = YES;
        _messageVoiceStatusImageView.contentMode = UIViewContentModeScaleAspectFit;
        _messageVoiceStatusImageView.image = [UIImage imageNamed:@"icon_voice_sender_3"] ;
        UIImage *image1 = [UIImage imageNamed:@"icon_voice_sender_1"];
        UIImage *image2 = [UIImage imageNamed:@"icon_voice_sender_2"];
        UIImage *image3 = [UIImage imageNamed:@"icon_voice_sender_3"];
        _messageVoiceStatusImageView.highlightedAnimationImages = @[image1,image2,image3];
        _messageVoiceStatusImageView.animationDuration = 1.5f;
        _messageVoiceStatusImageView.animationRepeatCount = NSUIntegerMax;
    }
    return _messageVoiceStatusImageView;
}
@end
