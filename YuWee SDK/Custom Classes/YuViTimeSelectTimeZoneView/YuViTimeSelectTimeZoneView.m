//
//  YuViTimeSelectTimeZoneView.m
//  YuViTime
//
//  Created by Abhishek Kumar on 7/24/17.
//  Copyright © 2017 DAT-Asset-158. All rights reserved.
//

#import "YuViTimeSelectTimeZoneView.h"

@interface YuViTimeSelectTimeZoneView () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *timeZoneTableView;

@end


@implementation YuViTimeSelectTimeZoneView {
   
}

+ (instancetype)initWithNib{
    
    return [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil] firstObject];
}

- (void)initializeTimeZones {
    
    [_timeZoneTableView reloadData];
    
}
- (void)showSelectedDefaultTimeZone{
    
    if (_index_defaultTimeZone!=0) {
        [_timeZoneTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_index_defaultTimeZone inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:false];
        [_timeZoneTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_index_defaultTimeZone inSection:0] animated:true scrollPosition:UITableViewScrollPositionMiddle];
    }
    
}


# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _timeZones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeZoneTableViewCellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"timeZoneTableViewCellIdentifier"];
    }
    
    cell.textLabel.text = [_timeZones objectAtIndex:indexPath.row];
    
    return cell;
}


# pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *selectedTimeZoneArray = [_timeZoneData objectAtIndex:indexPath.row];
    [self.delegate didSelectTimeZone:selectedTimeZoneArray];
}

@end
