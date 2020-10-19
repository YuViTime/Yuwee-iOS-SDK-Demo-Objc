//
//  YuviTimeStartCallView.h
//  YuViTime
//
//  Created by Mac-1 on 7/17/17.
//  Copyright © 2017 satabdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFTokenField.h"
#import "KLCPopup.h"

@class YuviTimeStartCallView;
@protocol YuviTimeStartCallViewDelegate <NSObject>

@optional - (void)didAddUsersWithEmails:(NSArray *)emails;
@optional - (void)didAddUsersWithEmails:(NSArray *)emails andGroupName:(NSString *)groupName;
@optional - (void)txtFieldEditingDidChange:(UITextField *)sender;
@optional - (void)didBeginToAddParticipants;
@optional - (void)txtFieldShouldBeginEditing:(UITextField *)sender;

@end


@interface YuviTimeStartCallView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintTopMarginOfAddButton;
@property (weak, nonatomic) IBOutlet UILabel *lblTopPlaceHolderBorder;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintHeightOfTopPlaceholder;
@property (weak ,nonatomic)   id <YuviTimeStartCallViewDelegate> delegate_StartCall;
@property (assign,nonatomic) CGFloat viewConstraint_Constant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (strong, nonatomic) IBOutlet UITextField *txtGroupName;
@property (strong, nonatomic) IBOutlet UITextField *txtSearchContact;
@property (strong ,nonatomic) NSArray *arrExistingUsers;
@property (strong ,nonatomic) NSString *userEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblInviteStringPlaceholder;
@property (weak,nonatomic) KLCPopup *popUpInvite;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet ZFTokenField *addedParticipantsListView;
@property (assign, nonatomic) BOOL isGroupContactsEnabled, isGroup;

+ (instancetype)initWithNib;
- (IBAction)btnDismissPopupClicked:(UIButton *)sender;
- (void)initialize;
- (IBAction)txtFieldEditingDidChange:(UITextField *)sender;

@end
