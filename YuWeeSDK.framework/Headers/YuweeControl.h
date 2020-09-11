//
//  YuweeControl.h
//  YuWee
//
//  Created by Arijit Das on 22/04/20.
//  Copyright © 2020 DAT-Asset-158. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YuweeControlViewDelegate <NSObject>

@optional - (void)hideVideoPressed:(BOOL)isSelected;
@optional - (void)hideAudioPressed:(BOOL)isSelected;
@optional - (void)openChatPressed:(BOOL)isSelected;
@optional - (void)switchSpeakerPressed:(BOOL)isSelected;
@optional - (void)endCallPressed:(id)sender;

@end

@interface YuweeControl : UIView

@property (strong, nonatomic) IBOutlet UIView *viewBg;
@property (strong, nonatomic) IBOutlet UIButton *btnChat;
@property (strong, nonatomic) IBOutlet UIButton *btnMuteVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnMuteAudio;
@property (strong, nonatomic) IBOutlet UIButton *hangupButton;
@property (strong, nonatomic) IBOutlet UIButton *btnSwitchSpeaker;
@property (strong, nonatomic) IBOutlet UILabel *lblChatBadgeCount;
@property (weak ,nonatomic) id <YuweeControlViewDelegate> delegate;

+ (instancetype)initWithNib;
- (void)initialize;

@end

NS_ASSUME_NONNULL_END
