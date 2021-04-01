//
//  NewDashboardViewController.m
//  YuWee SDK
//
//  Created by Tanay on 15/02/21.
//  Copyright © 2021 Prasanna Gupta. All rights reserved.
//

#import "NewDashboardViewController.h"
#import <MMWormhole/MMWormhole.h>
#import "CallController.h"
#import "CallViewController.h"
#import "ViewController.h"

@interface NewDashboardViewController ()

@end

@implementation NewDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.navigationController.navigationBar.hidden = true;
    self.navigationItem.title = @"iOS SDK Demo App";
    
    
    UIBarButtonItem *item= [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(didClickLogoutButton)];
    [self.navigationItem setRightBarButtonItem:item animated:TRUE];
    
   NSLog(@"isConnected: %d",[[Yuwee sharedInstance] getConnectionManager].isConnected);
    
    MMWormhole *wormHole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.yuwee.sdkdemo.new"
                                                         optionalDirectory:@"wormhole"];
    [wormHole passMessageObject:@{@"name" : @"Tanay"} identifier:@"data"];
    
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"];
    [ud setValue:@"Tanay Mondal" forKey:@"name"];
    [ud setObject:@"Tanay Mondal" forKey:@"my_name"];
    [ud synchronize];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"isConnected: %d",[[Yuwee sharedInstance] getConnectionManager].isConnected);
    if (![[Yuwee sharedInstance] getConnectionManager].isConnected) {
        [[[Yuwee sharedInstance] getConnectionManager] forceReconnect];
    }
    
    [[[Yuwee sharedInstance] getCallManager] setIncomingCallEventDelegate:self];
}

-(void)didClickLogoutButton{
    [[[Yuwee sharedInstance] getUserManager] logout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"unwindToLogin" sender:self];
    });
    
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onIncomingCall:(NSDictionary *)callData {
    [[AppDelegate sharedInstance] showIncomingCallingScreen:callData];
}

- (void)onIncomingCallAcceptSuccess:(NSDictionary *)callData {
    if ([callData[kisGroup] boolValue]) {
        [self presentGroupCallScreen:true];
    } else {
        [self presentCallScreen:true withCallDict:callData];
    }
}

- (void)onIncomingCallRejectSuccess:(NSDictionary *)callData {
    
}

- (void)presentGroupCallScreen:(BOOL)isIncoming withGroupName:(NSString *)groupName andMembers:(NSArray *)arrMembers{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = true;
    callControllerVC.strGroupName = groupName;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.arrMembers = [arrMembers mutableCopy];
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
}

- (void)presentCallScreen:(BOOL)isIncoming withCallDict:(NSDictionary*)callDict{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallController *calVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
    calVC.isGroupCall = false;
    calVC.dictCall = callDict;
    calVC.isIncomingCall = isIncoming;
    calVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calVC];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)presentGroupCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = true;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    [self presentViewController:navigationController animated:true completion:nil];
}

@end
