//
//  YuviTimeAddMemberPopUpView.h
//  YuWee
//
//  //Created by Yuwee on 19/12/19.
//  Copyright © 2019 DAT-Asset-158. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFTokenField.h"
#import "KLCPopup.h"
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YuviTimeAddMemberPopUpViewDelegate <NSObject>

@optional - (void)didAddUsersWithEmails:(NSArray *)emails;
@optional - (void)txtFieldEditingDidChange:(UITextField *)sender;
@optional - (void)didBeginToAddParticipants;
@optional - (void)txtFieldShouldBeginEditing:(UITextField *)sender;

@end

@interface YuviTimeAddMemberPopUpView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintTopMarginOfAddButton;
@property (weak, nonatomic) IBOutlet UILabel *lblTopPlaceHolderBorder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintHeightOfTopPlaceholder;
@property (weak ,nonatomic) id <YuviTimeAddMemberPopUpViewDelegate> delegate_addMember;
@property (assign,nonatomic) CGFloat viewConstraint_Constant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (strong, nonatomic) IBOutlet UITextField *txtSearchContact;
@property (strong ,nonatomic) NSArray *arrExistingUsers;
@property (strong ,nonatomic) NSString *userEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblInviteStringPlaceholder;
@property (weak,nonatomic) KLCPopup *popUpInvite;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet ZFTokenField *addedParticipantsListView;
@property (assign, nonatomic) BOOL isGroupContactsEnabled;

- (IBAction)btnDismissPopupClicked:(UIButton *)sender;
+ (instancetype)initWithNib;
- (void)initialize;
- (IBAction)txtFieldEditingDidChange:(UITextField *)sender;

@end

NS_ASSUME_NONNULL_END
