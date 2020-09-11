//
//  InitParam.h
//  YuWeeSDK
//
//  Created by Arijit Das on 13/04/20.
//  Copyright © 2020 yuwee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InitParam : NSObject

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSString *accessToken;

@end

NS_ASSUME_NONNULL_END
