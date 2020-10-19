//
//  CustomMessageCell.h
//  YuWee SDK
//
//  //Created by Yuwee on 30/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMessage;

@end

NS_ASSUME_NONNULL_END
