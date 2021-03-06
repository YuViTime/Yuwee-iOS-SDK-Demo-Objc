//
//  LoginViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 22/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "LoginViewController.h"
//#import <YuWeeSDK/YuweeSocketManager.h>
//#import <YuWeeSDK/SessionHandler.h>
//#import <YuWeeSDK/RecentCallManager.h>
#import "CallController.h"
#import "DashboardViewController.h"

@interface LoginViewController (){
    
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController


- (void)viewDidLoad{
    
   //self.navigationController.navigationBarHidden = YES;
    
    self.navigationItem.title = @"Login";
    
   UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
   [self.view addGestureRecognizer:gestureRecognizer];
   self.view.userInteractionEnabled = YES;
   gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:true];
}

- (void) openDashboardController{
    
    self.navigationController.navigationBar.hidden = true;
    [self performSegueWithIdentifier:@"dashboardSegue" sender:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:false];
    BOOL loggedIn = [[UserManager sharedInstance] isLoggedIn];
    if (loggedIn) {
        [self openDashboardController];
    }
}

-(IBAction)onRegistrationPressed:(id)sender {
    NSLog(@"On Registration Pressed");
    
}

-(IBAction)onLoginPressed:(id)sender {
    NSLog(@"On Login Pressed");
    
    if (![self isStringIsValidEmail:self.emailTextField.text]){
        [self showAlert:@"Email is not valid." : false];
        return;
    }
    else if (self.passwordTextField.text.length < 6 || self.passwordTextField.text.length > 20){
        [self showAlert:@"Password must be between 6 to 20 characters." : false];
        return;
    }
    else {
        
    #if !TARGET_IPHONE_SIMULATOR
        NSDictionary *dictTokens = [[[NSUserDefaults alloc] initWithSuiteName:@"123"] objectForKey:@"dictTokens"];
        if (dictTokens != nil) {
            [[[Yuwee sharedInstance] getUserManager] createSessionViaCredentialsWithEmail:self.emailTextField.text Password:self.passwordTextField.text ExpiryTime:@"200000" withCompletionBlock:^(BOOL isSessionCreateSuccess, NSDictionary *dictSessionCreateResponse) {
                if(isSessionCreateSuccess){
                    [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][k_Id] forKey:k_Id];
                    [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][kName] forKey:kName];
                    [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][kEmail] forKey:kEmail];
                    [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[@"access_token"] forKey:kToken];
                    
                    
                    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][k_Id] forKey:@"ss_user_id"];
                    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][kName] forKey:@"ss_nick_name"];
                    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][kEmail] forKey:@"ss_email"];
                    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[@"access_token"] forKey:@"ss_auth_token"];
                    
                    
                    NSMutableDictionary *dictUser = [dictSessionCreateResponse[kResult][kUser] mutableCopy];
                    
                    //Removing null values from available keys
                    NSArray *arrAllKeys = [dictUser allKeys];
                    NSArray *arrAllValues = [dictUser allValues];
                    
                    for (int i=0; i<[arrAllKeys count]; i++){
                        if ([[arrAllValues objectAtIndex:i] isKindOfClass:[NSNull class]]){
                            [dictUser removeObjectForKey:[arrAllKeys objectAtIndex:i]];
                        }
                    }
                    
                    [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictUser forKey:kUser];
                    
                    InitParam *initParam = [[InitParam alloc] init];
                    
                    initParam.userInfo = dictUser;
                    initParam.accessToken = dictSessionCreateResponse[@"access_token"];
                    
                    [[[Yuwee sharedInstance] getUserManager] createSessionViaToken:initParam withCompletionBlock:^(BOOL isSuccess, NSString *error) {
                        if (isSuccess) {
                            [[[Yuwee sharedInstance] getUserManager] registerPushTokenAPNS:dictTokens[@"apns"] VOIP:dictTokens[@"voip"] withCompletionBlock:^(BOOL isSuccess, NSString *error) {
                                [self openDashboardController];
                            }];
                        }
                    }];
                }
            }];
        } else {
            [[AppDelegate sharedInstance] pushRegistrationAndGetToken:^(NSDictionary *dictTokens) {
                [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictTokens forKey:@"dictTokens"];
                [[[Yuwee sharedInstance] getUserManager] createSessionViaCredentialsWithEmail:self.emailTextField.text Password:self.passwordTextField.text ExpiryTime:@"200000" withCompletionBlock:^(BOOL isSessionCreateSuccess, NSDictionary *dictSessionCreateResponse) {
                    if(isSessionCreateSuccess){
                        [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][k_Id] forKey:k_Id];
                        [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][kName] forKey:kName];
                        [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][kEmail] forKey:kEmail];
                        [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[@"access_token"] forKey:kToken];
                        
                        [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][k_Id] forKey:@"ss_user_id"];
                        [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][kName] forKey:@"ss_nick_name"];
                        [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[kResult][kUser][kEmail] forKey:@"ss_email"];
                        [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.yuwee.sdkdemo.new"] setValue:dictSessionCreateResponse[@"access_token"] forKey:@"ss_auth_token"];
                        
                        
                        NSMutableDictionary *dictUser = [dictSessionCreateResponse[kResult][kUser] mutableCopy];
                        
                        //Removing null values from available keys
                        NSArray *arrAllKeys = [dictUser allKeys];
                        NSArray *arrAllValues = [dictUser allValues];
                        
                        for (int i=0; i<[arrAllKeys count]; i++){
                            if ([[arrAllValues objectAtIndex:i] isKindOfClass:[NSNull class]]){
                                [dictUser removeObjectForKey:[arrAllKeys objectAtIndex:i]];
                            }
                        }
                        
                        [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictUser forKey:kUser];
                        
                        [[[Yuwee sharedInstance] getUserManager] registerPushTokenAPNS:dictTokens[@"apns"] VOIP:dictTokens[@"voip"] withCompletionBlock:^(BOOL isSuccess, NSString *error) {
                            [self openDashboardController];
                        }];
                    }
                }];
            }];
        }
    #else
        [[[Yuwee sharedInstance] getUserManager] createSessionViaCredentialsWithEmail:self.emailTextField.text Password:self.passwordTextField.text ExpiryTime:@"200000" withCompletionBlock:^(BOOL isSessionCreateSuccess, NSDictionary *dictSessionCreateResponse) {
            
            //[self showAlert :[dictSessionCreateResponse valueForKey:@"message"] :isSessionCreateSuccess];
            
            if(isSessionCreateSuccess){
                [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][k_Id] forKey:k_Id];
                [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][kName] forKey:kName];
                [[[NSUserDefaults alloc] initWithSuiteName:@"123"] setObject:dictSessionCreateResponse[kResult][kUser][kEmail] forKey:kEmail];
                
                [self openDashboardController];
            }
        }];
    #endif
    
    }
    
    
}

- (void)showAlert: (NSString*) text : (BOOL) isSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:isSuccess ? @"Success" : @"Error"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(BOOL)isStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)unwind:(UIStoryboardSegue *)sender {
    
}

@end
