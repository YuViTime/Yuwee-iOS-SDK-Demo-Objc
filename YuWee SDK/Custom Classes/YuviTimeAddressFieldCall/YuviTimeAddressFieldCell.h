//
//  YuviTimeAddressFieldCell.h
//  YuViTime
//
//  Created by Mac-1 on 7/25/17.
//  Copyright © 2017 DAT-Asset-158. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YuviTimeAddressFieldCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblEmail;
@property (strong, nonatomic) IBOutlet UIImageView *imgUser;
@property (strong, nonatomic) IBOutlet UIImageView *imgClose;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintForImageWidth;
@end
