//
//  ChatViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 28/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "ChatListViewController.h"
//#import <YuWeeSDK/ChatController.h>
#import "ChatDetailsViewController.h"

@interface ChatListViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>{
    NSMutableArray* array;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation ChatListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    array = [[NSMutableArray alloc] init];
    [self getChatList];
}

- (void)showDeleteAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                    message:@"Delete selected chat?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (BOOL)isStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

- (void)processCreateChat:(NSString *) enteredEmails{
    NSArray *items = [enteredEmails componentsSeparatedByString:@","];
    
    if ([items count]>0) {
        NSMutableArray *validEmail = [[NSMutableArray alloc] init];
        if (items.count == 1) {
            NSString *email = (NSString *) [items objectAtIndex:0];
            if ([self isStringIsValidEmail: email]) {
                [validEmail addObject:email];
            } else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Please enter email to create chat."
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"OK", nil];
                [alert show];
                return;
            }
        } else {
            for (int i = 0; i < items.count; i++) {
                NSString *email = (NSString *) [items objectAtIndex:i];
                if ([self isStringIsValidEmail: email]) {
                    [validEmail addObject:email];
                } else {
                    return;
                }
            }
        }
        
        if ([validEmail count]>0) {
            [self fetchRoomWithEmails:validEmail];
        }
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Please enter email to create chat."
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)fetchRoomWithEmails:(NSArray *) array{
    [[[Yuwee sharedInstance] getChatManager] fetchChatRoomByEmails:array withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictChatResponse) {
        if (isSuccess) {
            NSLog(@"%@", dictChatResponse);
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatDetailsViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatDetailsViewController"];
            
            chatVC.nsDict = dictChatResponse[kResult][kRoom];
            
            [self.navigationController pushViewController:chatVC animated:false];
        }
    }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        if (buttonIndex != 0) {
            NSLog(@"Entered Emails: %@",[[alertView textFieldAtIndex:0] text]);
            NSString *enteredEmails = [[alertView textFieldAtIndex:0] text];
            [self processCreateChat:enteredEmails];
        }
    }
    else{
        if (buttonIndex == 0) {
            NSLog(@"user pressed Cancel");
        }
        else {
            NSLog(@"user pressed OK");
            NSDictionary *mDict = [array objectAtIndex:self.selectedIndexPath.row];
            [[[Yuwee sharedInstance] getChatManager] deleteChatRoom:mDict[@"_id"] withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictChatResponse) {
                if (isSuccess) {
                    NSLog(@"%@", dictChatResponse);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%ld", self.selectedIndexPath.row);
                        [self->array removeObjectAtIndex:self.selectedIndexPath.row];
                        //NSArray *indexArray = [[NSArray alloc] initWithObjects:self->selectedIndexPath, nil];
                        [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    });
                }
            }];
        }
    }
}

- (void) getChatList{
    [[[Yuwee sharedInstance] getChatManager] fetchChatListWithCompletionBlock:^(BOOL isSuccess,NSDictionary *dictChatResponse){
        if (isSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray* mArray = dictChatResponse[@"result"][@"results"];
                self->array = mArray;
                dispatch_async(dispatch_get_main_queue(),^{
                   [[self tableView] reloadData];
                });
            });
        }
        else{
            NSLog(@"%@", dictChatResponse);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"chatListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    cell.tag = indexPath.row;
    [cell addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                             initWithTarget:self action:@selector(handleLongPress:)];
            lpgr.minimumPressDuration = 0.5; //seconds
            [cell addGestureRecognizer:lpgr];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *mDict = [array objectAtIndex:indexPath.row];
    NSString *nameToShow, *messageToShow;
    if ([mDict[@"isGroupChat"] boolValue]) {
        nameToShow = mDict[@"groupInfo"][@"name"];
    }
    else{
        NSString* myId = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"_id"];
        NSArray *memberArray = mDict[@"membersInfo"];
        for (NSDictionary* md in memberArray) {
            if (![md[@"_id"] isEqualToString:myId]) {
                nameToShow = md[@"name"];
                break;
            }
        }
    }
    
    if (![mDict[@"lastMessage"] isKindOfClass:[NSNull class]]) {
        NSString *messageType = mDict[@"lastMessage"][@"messageType"];
        if (messageType && [messageType caseInsensitiveCompare:@"call"] == NSOrderedSame) {
            messageToShow = @"Call";
        }
        else if(messageType && [messageType caseInsensitiveCompare:@"file"] == NSOrderedSame){
            messageToShow = @"File";
        }
        else{
            messageToShow = mDict[@"lastMessage"][@"message"];
        }
    }
    else{
        messageToShow = @"N/A";
    }
    
    
    
    cell.textLabel.text = nameToShow;
    cell.detailTextLabel.text = messageToShow;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"chatDetailsSegue"]) {
        ChatDetailsViewController *destViewController = (ChatDetailsViewController*) segue.destinationViewController;
        //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        destViewController.nsDict = [array objectAtIndex:self.selectedIndexPath.row];
    }
}

- (void)cellTapped:(UITapGestureRecognizer*)sender{
    CGPoint p = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"%ld", (long)indexPath.row);
    self.selectedIndexPath = indexPath;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES animated:YES];
    
    //[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self performSegueWithIdentifier:@"chatDetailsSegue" sender:self];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *) sender
{
   // [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if(sender.state==UIGestureRecognizerStateBegan){
        CGPoint p = [sender locationInView:self.tableView];
          NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
          self.selectedIndexPath = indexPath;
          NSLog(@"%ld", (long)indexPath.row);
          UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
          [cell setSelected:YES animated:YES];
        
        [self showDeleteAlert];
    }
}

- (IBAction)onNewChatPressed:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Create New Chat"
                                                     message:@"Enter members seperated by commas!"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert setTag:0];
    [alert show];
}

-(IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

@end
