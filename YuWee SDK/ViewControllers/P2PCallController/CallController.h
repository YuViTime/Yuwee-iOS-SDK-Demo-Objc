//
//  CallController.h
//  YuWee SDK
//
//Created by Yuwee on 29/07/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <YuWeeSDK/Yuwee.h>
#import "AppDelegate.h"
#import "YuviTimeStartCallView.h"


@class YuviTimeStartCallView;

@interface CallController : UIViewController <YuWeeCallManagerDelegate,YuWeeCallSetUpDelegate,YuWeeOnMemberAddedOnCallDelegate>
{
    YuviTimeStartCallView *viewInvite;
    KLCPopup *popUpInvite;
    CGRect rectSmallCallViewDefaultConstrains;
}
@property(nonatomic,copy)NSString *strEmailAddress;
@property(nonatomic,assign)BOOL isGroupCall,isIncomingCall,isAddMemberOnFly;
@property(nonatomic,assign)BOOL isCallTypeVideo;
@property(nonatomic,strong)NSArray *arrMembers;
@property (strong, nonatomic) IBOutlet UILabel *lblChatCount;
@property (strong, nonatomic) NSDictionary *dictCall;
@property (strong, nonatomic) IBOutlet YuweeRemoteVideoView *remoteView;
@property (nonatomic) IBOutlet YuweeLocalVideoView *localView;

- (IBAction)btnHideShowVideo:(UIButton *)sender;

@end
