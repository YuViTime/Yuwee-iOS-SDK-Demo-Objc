//
//  ChatDetailsViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 29/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "ChatDetailsViewController.h"
#import "CustomMessageCell.h"
#import "MessageDetails.h"
//#import <YuWeeSDK/ChatController.h>

@interface ChatDetailsViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, YuWeeNewMessageReceivedDelegate, YuWeeTypingEventDelegate, YuWeeMessageDeletedDelegate, YuWeeMessageDeliveredDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, YuWeeFileUploadDelegate>{
    NSString *roomId;
    NSMutableArray *array;
}
@property (weak, nonatomic) IBOutlet UIButton *btnClearRoom;
@property (weak, nonatomic) IBOutlet UITextField *mTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation ChatDetailsViewController

- (void)onUserTypingInRoom:(NSDictionary*)dictObject{
    NSLog(@"%@", dictObject);
}

- (void)onNewMessageReceived:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);
    
    MessageDetails *messageDetails = [[MessageDetails alloc] init];
    messageDetails.browserMessageId = [self getCurrentTimeStamp];
    messageDetails.message = dictParameter[@"message"];
    messageDetails.messageType = dictParameter[@"messageType"];
    messageDetails.senderName = dictParameter[@"sender"][@"name"];
    messageDetails.senderId = dictParameter[@"sender"][@"senderId"];
    messageDetails.senderEmail = dictParameter[@"sender"][@"email"];
    
    [array addObject:messageDetails];
    
    [[self myTableView] reloadData];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: %@", info);
    NSString *imageUrl = info[@"UIImagePickerControllerImageURL"];
    //NSURL *url = [[NSURL alloc] initWithString:imageUrl];
    NSData *data = [[NSData alloc] initWithContentsOfFile:imageUrl];
   
    [[[[Yuwee sharedInstance] getChatManager] getFileManager] sendFileWithRoomId:roomId withUniqueIdentifier:[self getCurrentTimeStamp] withFileData:data withFileName:@"test_file_name" withFileExtension:@"jpg" withFileSize:0 withDelegate:self];
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void) onUploadSuccess{
    NSLog(@"onUploadSuccess");
}

- (void) onUploadStarted{
    NSLog(@"onUploadStarted");
}

- (void) onUploadFailed{
    NSLog(@"onUploadFailed");
}

- (void) onProgressUpdateWithProgress:(double)progress{
    NSLog(@"onProgressUpdateWithProgress %f", progress);
}

- (IBAction)onSendFilePressed:(id)sender {
    
    UIImagePickerController *myImagePicker = [[UIImagePickerController alloc] init];
    myImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePicker.delegate = self;
    [self presentViewController:myImagePicker animated:YES completion:nil];
    
    //jsonObject.put("fileName", fileName);
    //jsonObject.put("fileExtension", "png");
    //jsonObject.put("fileSize", "200");
    //jsonObject.put("downloadUrl", fileUrl);
    
//    MessageDetails *messageDetails = [[MessageDetails alloc] init];
//    messageDetails.browserMessageId = [self getCurrentTimeStamp];
//    messageDetails.message = @"FILE SENT";
//    messageDetails.messageType = @"file";
//    messageDetails.senderName = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"name"];
//    messageDetails.senderId = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"id"];
//    messageDetails.senderEmail = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"email"];
//
//    [array addObject:messageDetails];
//
//    NSString *fileUrl = @"https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png";
//
//    NSDictionary *fileDict = @{@"fileName":@"google",
//                               @"fileExtension":@"png",
//                               @"fileSize":@"200",
//                               @"downloadUrl":fileUrl};
//
//    [[[Yuwee sharedInstance] getChatManager] shareFile:roomId messageIdentifier:messageDetails.browserMessageId fileDictionary:fileDict quotedMessageId:nil];
//
//    [[self myTableView] reloadData];
}

- (IBAction)onClearPressed:(id)sender {
    [self showClearAlert];
}

- (IBAction)onSendPressed:(id)sender {
    
    if (self.mTextField.text.length<1) {
        return;
    }
    
    MessageDetails *messageDetails = [[MessageDetails alloc] init];
    messageDetails.browserMessageId = [self getCurrentTimeStamp];
    messageDetails.message = self.mTextField.text;
    messageDetails.messageType = @"text";
    messageDetails.senderName = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"name"];
    messageDetails.senderId = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"id"];
    messageDetails.senderEmail = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"email"];
    
    [array addObject:messageDetails];
    
    [[self myTableView] reloadData];
    //NSString* aesKey = (NSString*)[self nsDict][@"aesKey"];
    NSString *msg = (NSString*) self.mTextField.text;
    [[ChatManager sharedInstance] sendMessage:msg toRoomId:roomId messageIdentifier:messageDetails.browserMessageId withQuotedMessageId:nil];

    [[[Yuwee sharedInstance] getChatManager] sendTypingStatusToRoomId:roomId];
    self.mTextField.text = @"";
}

- (NSString *) getCurrentTimeStamp {
    //Returns current time stamp
    return [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (void)viewDidLoad{
    NSLog(@"%@", self.nsDict);
    roomId = [self nsDict][@"_id"];
    
    NSString *nameToShow;
    if ([[self nsDict][@"isGroupChat"] boolValue]) {
        nameToShow = [self nsDict][@"groupInfo"][@"name"];
        [self removeMemberInGroup];
    }
    else{
        NSString* myId = (NSString*) [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"_id"];
        NSArray *memberArray = [self nsDict][@"membersInfo"];
        for (NSDictionary* md in memberArray) {
            if (![md[@"_id"] isEqualToString:myId]) {
                nameToShow = md[@"name"];
                [self getUserLastSeenWithUserId:md[@"_id"]];
                break;
            }
        }
    }
    
    self.senderName.text = nameToShow;
    array = [[NSMutableArray alloc] init];
    [self getRoomMessage];
    [self markAllMessagesAsRead];
    
    [[[Yuwee sharedInstance] getChatManager] setNewMessageReceivedDelegate:self];
    [[[Yuwee sharedInstance] getChatManager] setTypingEventDelegate:self];
    [[[Yuwee sharedInstance] getChatManager] setMessageDeleteDelegate:self];
    [[[Yuwee sharedInstance] getChatManager] setMessageDeliveredDelegate:self];
    //[self forwardMessage];
    
    [[[[Yuwee sharedInstance] getChatManager] getFileManager] initFileShareWithRoomId:roomId withCompletionBlock:^(NSString *message, BOOL success) {
        NSLog(@"File sharing: %d %@", success, message);
    }];
    
    [[[[Yuwee sharedInstance] getChatManager] getFileManager] getFileUrlWithFileId:@"5fe3040c2eb4513ceeb049f7" withFileKey:@"media/5fa3df498cb9b56d05ef9b33/5fbfb6d332033213ab687a9f/test_file_name" withCompletionBlock:^(NSString *message, BOOL success) {
            NSLog(@"URL: %@", message);
    }];
}


- (void)onMessageDelivered:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);
}

- (void)onMessageDeleted:(NSDictionary *)dictParameter{
    NSLog(@"%@", dictParameter);
    NSString *messageId = dictParameter[@"messageId"];
    for (int i = 0; i < array.count; i++) {
        MessageDetails *md = [array objectAtIndex:i];
        if ([[md.messageId uppercaseString] isEqualToString:[messageId uppercaseString]]) {
            [array removeObjectAtIndex:i];
            [[self myTableView] reloadData];
            return;
        }
    }
}


-(void) getUserLastSeenWithUserId:(NSString *) userId{
    [[[Yuwee sharedInstance] getChatManager] getUserLastSeen:userId withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictLastSeenResponse) {
        NSLog(@"%@", dictLastSeenResponse);
        if (isSuccess) {
            
        }
    }];
}

-(void) markAllMessagesAsRead {
    [[[Yuwee sharedInstance] getChatManager] markMessagesAsReadInRoomId:roomId];
}

-(void) getRoomMessage {
    [[[Yuwee sharedInstance] getChatManager] fetchChatMessagesForRoomId:roomId totalMessagesCountToSkip:0 withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictChatResponse) {
        if (isSuccess) {
            NSLog(@"%@", dictChatResponse);
            [self parseMessageData:dictChatResponse];
        }
        
    }];
}

-(void)parseMessageData:(NSDictionary *) nsDictionary {
    NSArray *mArray = nsDictionary[@"result"][@"result"][@"messages"];
    
    for (NSDictionary *mDict in mArray) {
        MessageDetails *messageDetails = [[MessageDetails alloc] init];
        messageDetails.messageType = mDict[@"messageType"];
        messageDetails.senderId = mDict[@"sender"][@"_id"];
        messageDetails.senderName = mDict[@"sender"][@"name"];
        messageDetails.senderEmail = mDict[@"sender"][@"email"];
        messageDetails.messageId = mDict[@"messageId"];
        
        if (mDict[@"messageType"] && [mDict[@"messageType"] caseInsensitiveCompare:@"call"] == NSOrderedSame) {
            messageDetails.message = [NSString stringWithFormat:@"%@ started a call", messageDetails.senderName];
        }
        else if (mDict[@"messageType"] && [mDict[@"messageType"] caseInsensitiveCompare:@"text"] == NSOrderedSame){
            messageDetails.message = mDict[@"message"];
        }
        else{
            messageDetails.fileUrl = mDict[@"fileInfo"][@"downloadUrl"];
        }
        
        [array addObject:messageDetails];
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
       [[self myTableView] reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = @"customMessageCell";
    CustomMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    MessageDetails *mDetails = (MessageDetails*) [array objectAtIndex:indexPath.row];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                             initWithTarget:self action:@selector(handleLongPress:)];
            lpgr.minimumPressDuration = 0.5; //seconds
            [cell addGestureRecognizer:lpgr];
    
    NSString *msg = @"";
    if ([[mDetails.messageType uppercaseString] isEqualToString:@"FILE"]) {
        msg = @"FILE";
    }
    else {
        msg = mDetails.message;
    }
    
    cell.userMessage.text = msg;
    cell.userName.text = mDetails.senderName;
    
    cell.userMessage.lineBreakMode = NSLineBreakByWordWrapping;
    cell.userMessage.numberOfLines = 0;
    
    return cell;
}

-(IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


- (void)showClearAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                    message:@"Clear all messages?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert setTag:1];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            NSLog(@"user pressed Cancel");
            
        }
        else if(buttonIndex == 1){
            NSLog(@"user pressed Delete for me");
            MessageDetails *messageDetails = [array objectAtIndex:self.selectedIndexPath.row];
           [[[Yuwee sharedInstance] getChatManager] deleteMessageForMessageId:messageDetails.messageId roomId:roomId deleteType:DELETE_FOR_ME withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictChatResponse) {
                if (isSuccess) {
                [self->array removeObjectAtIndex:self.selectedIndexPath.row];
                [self.myTableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                                }
            }];
        }
        else{
            NSLog(@"user pressed Delete for All");
            MessageDetails *messageDetails = [array objectAtIndex:self.selectedIndexPath.row];
            [[[Yuwee sharedInstance] getChatManager] deleteMessageForMessageId:messageDetails.messageId roomId:roomId deleteType:DELETE_FOR_ALL withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictChatResponse) {
                if (isSuccess) {
                    [self->array removeObjectAtIndex:self.selectedIndexPath.row];
                    [self.myTableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        }
    }
    else{
        if (buttonIndex == 0) {
            NSLog(@"user pressed Cancel");
            
        }
        else {
            NSLog(@"user pressed OK");
            
            [[[Yuwee sharedInstance] getChatManager] clearChatsForRoomId:roomId withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictChatResponse) {
                if (isSuccess) {
                    NSLog(@"%@", dictChatResponse);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->array removeAllObjects];
                        [self.myTableView reloadData];
                    });
                }
            }];
        
        }
    }
}

- (void)showDeleteAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                    message:@"Delete selected chat?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete for me", @"Delete for all", nil];
    [alert setTag:0];
    [alert show];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *) sender
{
   // [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if(sender.state==UIGestureRecognizerStateBegan){
        CGPoint p = [sender locationInView:self.myTableView];
          NSIndexPath *indexPath = [self.myTableView indexPathForRowAtPoint:p];
          self.selectedIndexPath = indexPath;
          NSLog(@"%ld", (long)indexPath.row);
          UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
          [cell setSelected:YES animated:YES];
        
        [self showDeleteAlert];
    }
}

- (void)addMemberInGroup{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:@"Yuweeyuwee+sdk3@gmail.com"];
    [[[Yuwee sharedInstance] getChatManager] addMembersInGroupByEmail:roomId withArrayOfEmails:array withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
        NSLog(@"%@", dictResponse);
    }];
}

- (void)removeMemberInGroup{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:@"Yuweeyuwee+sdk3@gmail.com"];
    [[[Yuwee sharedInstance] getChatManager] removeMembersFromGroupByEmail:roomId withArrayOfEmails:array withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
        NSLog(@"%@", dictResponse);
    }];
}

- (void) forwardMessage{
    // 5e42e3fa12275e08aabb3fb6
    [[[Yuwee sharedInstance] getChatManager] forwardMessage:@"hey Yuwee" withRoomId:roomId withMessageIdentifier:@"813691639136"];
}

@end
