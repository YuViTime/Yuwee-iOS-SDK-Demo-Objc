//
//  ContactModel.h
//  YuWee SDK
//
//  Created by Tanay on 04/02/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactModel : NSObject

@property (strong, nonatomic) NSString *name, *email, *phoneNumber, *companyName, *address, *jobTitle, *dob, *note, *contactImage;
-(NSDictionary *) dictionary;
- (NSString *) toJson:(NSObject *) object;

@end

NS_ASSUME_NONNULL_END
