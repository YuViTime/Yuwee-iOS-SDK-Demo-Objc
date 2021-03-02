//
//  NewDashboardViewController.m
//  YuWee SDK
//
//  Created by Tanay on 15/02/21.
//  Copyright © 2021 Prasanna Gupta. All rights reserved.
//

#import "NewDashboardViewController.h"
#import <MMWormhole/MMWormhole.h>

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

@end
