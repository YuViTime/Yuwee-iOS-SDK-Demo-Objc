//
//  CallViewController.h
//  YuWee SDK
//
//  //Created by Yuwee on 28/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "YuviTimeAddMemberPopUpView.h"
#import <YuWeeSDK/Yuwee.h>
#import <YuWeeSDK/YuweeControl.h>
#import "KLCPopup.h"
#import "AppDelegate.h"

@interface CallViewController : UIViewController <YuWeeCallManagerDelegate,YuWeeCallSetUpDelegate,YuweeControlViewDelegate>
{
    CGRect rectSmallCallViewDefaultConstrains;
}
@property(nonatomic,copy) NSString *strGroupName;
@property(nonatomic,assign)BOOL isGroupCall,isIncomingCall,isAddMemberOnFly;;
@property(nonatomic,assign)BOOL isCallTypeVideo;
@property(nonatomic,strong) NSMutableArray *arrMembers;
@property (strong, nonatomic) NSDictionary *dictCall;
@property (strong, nonatomic) YuweeControl *viewOfControls;
@property (strong, nonatomic) YuweeRemoteVideoView *remoteViewNew;
@property (strong, nonatomic) IBOutlet UIButton *btnVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnHangUp;
@property (strong, nonatomic) IBOutlet UIButton *btnAudio;
@property (strong, nonatomic) IBOutlet UIButton *btnSpeaker;
@property (strong, nonatomic) IBOutlet YuweeVideoView *videoView;
@property (strong, nonatomic) IBOutlet YuweeVideoView *screenView;

@end
