//
//  ContactViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 04/02/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "ContactViewController.h"
#import <YuWeeSDK/Yuwee.h>

@interface ContactViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.array = [[NSMutableArray alloc]init];
    self.navigationItem.title = @"Contact";
    
    //[self getContactDetails:@"5e3960c49b80cb27affc43f4"];
    
    //[self deleteContact];
    
    //[self getAllContactStatus];
    
    UIBarButtonItem *item= [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(didClickAddButton)];
    [self.navigationItem setRightBarButtonItem:item animated:TRUE];
}

-(void)didClickAddButton{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *objVC = [storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    [self.navigationController pushViewController:objVC animated:true];
}



- (void)getAllContactStatus{
    [[[Yuwee sharedInstance] getStatusManager] fetchAllContactsStatus:^(BOOL isSuccess, NSDictionary *dictResponse) {
        NSLog(@"%@", dictResponse);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [self getContactList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellId = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSDictionary *dict = [[self array] objectAtIndex:indexPath.row];
    cell.textLabel.text = dict[@"name"];
    cell.detailTextLabel.text = dict[@"email"];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                             initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    [cell addGestureRecognizer:lpgr];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dict = [[self array] objectAtIndex:indexPath.row];
        [self deleteContact:dict[@"_id"]];
        [self.array removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (IBAction)onAddPressed:(id)sender {
    
}


-(void) getContactDetails:(NSString *) contactId{
    [[[Yuwee sharedInstance] getContactManager] fetchContactDetailsWithContactId:contactId withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
        if (isSuccess) {
            NSLog(@"%@", dictResponse);
        }
    }];
}

-(void) getContactList {
    [[self array] removeAllObjects];
    [[[Yuwee sharedInstance] getContactManager] fetchContactList:^(BOOL isSuccess, NSDictionary *dictResponse) {
        if (isSuccess) {
            NSLog(@"%@", dictResponse);
            [[self array] addObjectsFromArray:dictResponse[@"result"]];
            [[self tableView] reloadData];
        }
    }];
}

-(void) deleteContact:(NSString*)contactId {
    [[[Yuwee sharedInstance] getContactManager] deleteContactWithContactId:contactId withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
        if (isSuccess) {
            NSLog(@"%@", dictResponse);
        }
    }];
}
- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
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
        
        [self showLongPressAlert];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        NSDictionary *mDict = [self->_array objectAtIndex:self.selectedIndexPath.row];
        [self getUserStatus:mDict[@"email"]];
    }
}
-(void)getUserStatus:(NSString*)contactId{
    [[[Yuwee sharedInstance] getStatusManager] getParticularUserStatusByEmail:contactId withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
        NSLog(@"%@", dictResponse);
        NSError *writeError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictResponse options:NSJSONWritingPrettyPrinted error:&writeError];
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self showStatusAlert:result];
    }];
}

- (void)showLongPressAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                    message:@"Get user status?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}

- (void)showStatusAlert:(NSString*)status {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                    message:status
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
