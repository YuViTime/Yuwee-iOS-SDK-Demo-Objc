//
//  RegisterViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 22/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController (){
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
-(void) showAlert: (NSString*) text : (BOOL) isSuccess;
@end

@implementation RegisterViewController

- (void)viewDidLoad{
    
   self.navigationController.navigationBarHidden = YES;
    
   UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
   [self.view addGestureRecognizer:gestureRecognizer];
   self.view.userInteractionEnabled = YES;
   gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:true];
}

-(IBAction)goBack:(id)sender {
    //[self removeFromParentViewController];
    [self.navigationController popViewControllerAnimated:true];
}


-(IBAction)onRegistrationPressed:(id)sender {
    
    if (self.nameTextField.text.length < 1) {
        [self showAlert:@"Name can't be empty." : false];
        return;
    }
    else if (![self isStringIsValidEmail:self.emailTextField.text]){
        [self showAlert:@"Email is not valid." : false];
        return;
    }
    else if (self.passwordTextField.text.length < 6 || self.passwordTextField.text.length > 20){
        [self showAlert:@"Password must be between 6 to 20 characters." : false];
        return;
    }
    
    [[[Yuwee sharedInstance] getUserManager] createUserWithName:self.nameTextField.text
                      Email:self.emailTextField.text
                   Password:self.passwordTextField.text
        withCompletionBlock:^(BOOL isCreateUserSuccess, NSDictionary *dictCreateUserResponse) {
        [self showAlert :[dictCreateUserResponse valueForKey:@"message"]
                        :isCreateUserSuccess];
    }];
    
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

@end
