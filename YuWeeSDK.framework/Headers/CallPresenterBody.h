//
//  CallPresenterBody.h
//  YuWee SDK
//
//  Created by Arijit Das on 23/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallPresenterBody : NSObject

@property (strong,nonatomic) NSString *userId;
@property (assign,nonatomic) BOOL isTempPresenter;

@end

NS_ASSUME_NONNULL_END
