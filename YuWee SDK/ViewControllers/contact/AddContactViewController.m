//
//  AddContactViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 18/02/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "AddContactViewController.h"
#import <YuWeeSDK/Yuwee.h>

@interface AddContactViewController ()<UIAlertViewDelegate>
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
        [self showAlert:@"Name must have more than 3 characters." withBool:false];
        return;
    }
    else if (![self isStringIsValidEmail:self.fEmail.text]){
        [self showAlert:@"Email is not valid." withBool:false];
        return;
    }
    else {
        ContactModel *contactModel = [[ContactModel alloc] init];
        contactModel.name = self.fName.text;
        contactModel.email = self.fEmail.text;
        [[[Yuwee sharedInstance] getContactManager] addContact:contactModel withCompletionBlock:^(BOOL isSuccess, NSDictionary *dictResponse) {
            //if (isSuccess) {
                [self showAlert:dictResponse[@"message"] withBool:isSuccess];
            //}
        }];
    }
    
}

- (void)showAlert:(NSString*)message withBool:(BOOL)isAddSuccess {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];

    if (isAddSuccess) {
        [alert setTag:1];
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:true];
    }
}
@end
