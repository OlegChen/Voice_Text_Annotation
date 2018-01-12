//
//  XHAudioImageView.h
//  测试
//
//  Created by Chen on 2017/6/18.
//  Copyright © 2017年 chenxianghong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LGVoicePlayState){
    LGVoicePlayStateNormal,/**< 未播放状态 */
    LGVoicePlayStateDownloading,/**< 正在下载中 */
    LGVoicePlayStatePlaying,/**< 正在播放 */
    LGVoicePlayStateCancel,/**< 播放被取消 */
};

@interface XHAudioImageView : UIImageView

@property (nonatomic ,strong) UILabel *labelTime;

@property (nonatomic ,strong) UIImageView *messageVoiceStatusImageView;


@property (nonatomic, assign) LGVoicePlayState voicePlayState;


@end
