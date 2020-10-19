//
//  AddContactViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 18/02/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "AddContactViewController.h"
#import <YuWeeSDK/Yuwee.h>

@interface AddContactViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fName;
@property (weak, nonatomic) IBOutlet UITextField *fEmail;

@end

@implementation AddContactViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)onAddPressed:(id)sender {
    if (self.fName.text.length < 3){
        [self showAlert:@"Name must have more than 3 characters."];
        return;
    }
    else if (![self isStringIsValidEmail:self.fEmail.text]){
        [self showAlert:@"Email is not valid."];
        return;
    }
    else {
        ContactModel *contactModel = [[ContactModel alloc] init];
        contactModel.name = self.fName.text;
        contactModel.email = self.fEmail.text;
        [[[Yuwee sharedInstance] getContactManager] addContact:contactModel withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
            //if (isSuccess) {
                [self showAlert:dictResponse[@"message"]];
            //}
        }];
    }
    
}

- (void)showAlert:(NSString*)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    //alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //[alert setTag:0];
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
