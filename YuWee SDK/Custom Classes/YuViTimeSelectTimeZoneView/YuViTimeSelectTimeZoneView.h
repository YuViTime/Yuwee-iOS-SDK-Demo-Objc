//
//  YuViTimeSelectTimeZoneView.h
//  YuViTime
//
//  Created by Abhishek Kumar on 7/24/17.
//  Copyright © 2017 DAT-Asset-158. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YuViTimeSelectTimeZoneViewDelegate <NSObject>

@required
- (void)didSelectTimeZone:(NSArray *)selectedTimeZoneArray;

@end

@interface YuViTimeSelectTimeZoneView : UIView {
}

@property (weak, nonatomic) id<YuViTimeSelectTimeZoneViewDelegate> delegate;
@property (strong ,nonatomic) NSArray *timeZoneData;
@property (strong ,nonatomic) NSMutableArray *timeZones;
@property (assign ,nonatomic) NSInteger index_defaultTimeZone;

+ (instancetype)initWithNib;

- (void)initializeTimeZones;

- (void)showSelectedDefaultTimeZone;

@end
