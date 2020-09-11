//
//  AddScheduleCallViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 18/02/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "AddScheduleCallViewController.h"
#import "YuViTimeSelectTimeZoneView.h"
#import "KLCPopup.h"
#import <YuWeeSDK/Yuwee.h>

#define kDaily @"Daily"
#define kWeekly @"Weekly"
#define kMonthly @"Monthly"
#define kYearly @"Yearly"

#define kEvery_Day @"EVERY_DAY"
#define kEvery_Week @"EVERY_WEEK"
#define kEvery_Month @"EVERY_MONTH"
#define kEvery_Year @"EVERY_YEAR"
#define kMinimumStartTime 7*60
#define kMaximumDate 31536000*5 //31536000 is no. of seconds in a year - 5 Years currently
#define kMinimumEndTime (10+7)*60  //(end margin + start time margin)* 60
#define kMinimumTimeDifferenceMargin 7
#define kTimeDifferenceMarginStartAndEndCall 60*10
#define kYuWeeThemeColor [UIColor colorWithRed:230.0/255.0f green:231.0/255.0f blue:233.0/255.0f alpha:1]

@interface AddScheduleCallViewController () <UITextFieldDelegate,YuViTimeSelectTimeZoneViewDelegate>
{
    YuViTimeSelectTimeZoneView *_timeZoneListView;
    KLCPopup *popUpInvite, *_selectTimeZonePopUp;
    UIDatePicker *_datePicker, *_timePicker,*endTimePicker;
    NSString *_callRepeatTypeString;
    NSDate *startDate;
    NSArray *_timeZoneData;
    NSArray *arrAlertBeforeMinutes;
    NSArray *_selectedTimeZone;
    NSString *timeZone;
    NSString *timeZoneStr;
    NSMutableArray *_timeZones;
}
@property (weak, nonatomic) IBOutlet UITextField *fEmails;
@property (weak, nonatomic) IBOutlet UITextField *fMeetingName;
@property (weak, nonatomic) IBOutlet UITextField *fTimeZone;
@property (weak, nonatomic) IBOutlet UITextField *fTypedaily;
@property (weak, nonatomic) IBOutlet UITextField *fTime;
@property (weak, nonatomic) IBOutlet UITextField *fDate;
@property (weak, nonatomic) IBOutlet UITextField *fNameVal;
@property (weak, nonatomic) IBOutlet UITextField *fEndTime;
@property (weak, nonatomic) IBOutlet UITextField *fRiminderInMinute;
@property (weak, nonatomic) IBOutlet UITextField *noRepeatReminderInMinutes;
@property (assign ,nonatomic) NSInteger index_defaultTimeZone;

@end

@implementation AddScheduleCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setDefaultTimeZone];
    [self setupOutlets];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    self.view.userInteractionEnabled = YES;
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:true];
}

- (IBAction)onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)onCreateMeetingPressed:(id)sender {
    if (![self processValidateEmails:self.fEmails.text]){
        [self showAlert:@"Entered email is not valid."];
        return;
    }
    else if (self.fMeetingName.text.length < 3){
        [self showAlert:@"Meeting name must have more than 3 characters."];
        return;
    }
    // do date and time checking
    else {
        NSTimeInterval secondsBetween = [endTimePicker.date timeIntervalSinceDate:_timePicker.date];
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
        [mDict setValue:self.fMeetingName.text forKey:@"schedulerName"];
        [mDict setValue:@"Test Meeting Description" forKey:@"schedulerDescription"];
        [mDict setValue:_fDate.text forKey:@"dateOfStart"]; // enter date
        [mDict setValue:_fTime.text forKey:@"time"]; // enter time
        [mDict setValue:[self timeFormattedToMinutes:secondsBetween] forKey:@"duration"];
        [mDict setValue:@"VIDEO" forKey:@"schedulerMedia"];
        [mDict setValue:[_selectedTimeZone objectAtIndex:1] forKey:@"timezone"];
        [mDict setValue:@"5" forKey:@"alertBeforeMeeting"];
        [mDict setValue:[_selectedTimeZone firstObject] forKey:@"shortTimeZone"];
        [mDict setValue:@"Kolkata" forKey:@"offsetName"];
        [mDict setValue:[self getValidEmails:self.fEmails.text] forKey:@"members"];
        
        [[[Yuwee sharedInstance] getCallManager] scheduleMeeting:mDict withCompletionBlock:^(BOOL isCallScheduledSuccess, NSDictionary *dictCallScheduleResponse) {
            NSLog(@"%@", dictCallScheduleResponse);
            [self.navigationController popViewControllerAnimated:true];
        }];
    }
}

- (void)setupOutlets {
    
    //Setup datepicker for selecting date
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker setDate:[NSDate date]];
    _datePicker.minimumDate = [NSDate date];
    NSDate *maxDate = [[NSDate date] dateByAddingTimeInterval:kMaximumDate];
    _datePicker.maximumDate = maxDate;
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    
    //  add 'Done' button on date picker
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,-40,self.view.frame.size.width,40)];
    [toolBar setBarStyle:UIBarStyleBlack];
    [toolBar setTranslucent:true];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(updateEndTimeAndRemoveDatePickerView)];
    
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor whiteColor];
    
    [_datePicker addTarget:self
                    action:@selector(updateDateOfCallTextField)
          forControlEvents:UIControlEventAllEvents];
    
    _datePicker.tintColor = [UIColor blackColor];
    
    [_fDate setInputView:_datePicker];
    [_fDate setInputAccessoryView:toolBar];
    
    //  setup timepicker for selecting time
    _timePicker = [[UIDatePicker alloc] init];
    [_timePicker setDate:[[NSDate date] dateByAddingTimeInterval:kMinimumStartTime]];
    _timePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:kMinimumStartTime];

    _timePicker.tintColor = [UIColor whiteColor];
   
    [_timePicker setDatePickerMode:UIDatePickerModeTime];
    
    //  add 'Done' button on date picker
    UIToolbar *tB = [[UIToolbar alloc] initWithFrame:CGRectMake(0,-40,self.view.frame.size.width,40)];
    [tB setBarStyle:UIBarStyleBlack];
    [tB setTranslucent:true];
    UIBarButtonItem *barDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(updateStartTimeAndRemoveTimePickerView)];
    tB.items = @[barDoneButton];
    barDoneButton.tintColor=[UIColor whiteColor];
    
    [_timePicker addTarget:self
                    action:@selector(updateStartTimeOfCallTextField)
          forControlEvents:UIControlEventAllEvents];
    
    [_fTime setInputView:_timePicker];
    [_fTime setInputAccessoryView:tB];
    
    UIToolbar *tB_EndTime = [[UIToolbar alloc] initWithFrame:CGRectMake(0,-40,self.view.frame.size.width,40)];
    [tB_EndTime setBarStyle:UIBarStyleBlack];
    [tB_EndTime setTranslucent:true];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(updateAndRemoveEndTimePickerView)];
    tB_EndTime.items = @[barButton];
    barButton.tintColor=[UIColor whiteColor];
    endTimePicker = [[UIDatePicker alloc] init];
    [endTimePicker setDate:[[NSDate date] dateByAddingTimeInterval:kMinimumEndTime]];
    endTimePicker.tintColor = [UIColor whiteColor];
    [endTimePicker setDatePickerMode:UIDatePickerModeTime];
    [endTimePicker addTarget:self
                    action:@selector(updateEndTimeOfCallTextField:)
          forControlEvents:UIControlEventAllEvents];
    [_fEndTime setInputView:endTimePicker];
    [_fEndTime setInputAccessoryView:tB_EndTime];
    
}


- (void)updateDateOfCallTextField{
    //    NSLog(@"%s",__PRETTY_FUNCTION__);
    //Update time limit when date is selected
    if (_fDate.text.length){
        _fTime.text = @"";
        _fEndTime.text = @"";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[NSString stringWithFormat:@"%@",timeZoneStr]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    _fDate.text = [dateFormatter stringFromDate:_datePicker.date];
    
    NSString * todayString = [[[NSDate date] description] substringToIndex:10];
    NSString * refDateString = [[_datePicker.date description] substringToIndex:10];
    
    if ([refDateString isEqualToString:todayString]){
        //Do Today.... set minimum time limit if current date selected
        _timePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:kMinimumStartTime];
        _timePicker.date = _timePicker.minimumDate;
    }else{
        //Reset time limit if selcted date is not current date
        _timePicker.minimumDate = nil;
        
    }
    
    //Reset remind me before option
    _fRiminderInMinute.tag = 0;
    _fRiminderInMinute.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[_fRiminderInMinute.tag] intValue]];
    
    [_fDate resignFirstResponder];
}


- (void)updateAndRemoveEndTimePickerView {
    //end time done button click event
    [self updateEndTimeOfCallTextField:endTimePicker];
    [_fEndTime resignFirstResponder];
    
}


/*
 * @Method Name : updateEndTimeOfCallTextField:(UIDatePicker*)_endTimePicker
 * @purpose     : Method used to update end Time
 * @parameters  : nil
 */
- (void)updateEndTimeOfCallTextField:(UIDatePicker*)_endTimePicker{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[NSString stringWithFormat:@"%@",timeZoneStr]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    _fEndTime.text = [dateFormatter stringFromDate:_endTimePicker.date];
}


/*
 * @Method Name : updateStartTimeAndRemoveTimePickerView
 * @purpose     : Method used to update Start Time And Remove Time Picker View
 * @parameters  : nil
 */
- (void)updateStartTimeAndRemoveTimePickerView{
    //start time done button click event
    [self updateStartTimeOfCallTextField];
    [_fTime resignFirstResponder];
    
}


- (void)updateStartTimeWithCurrentData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[NSString stringWithFormat:@"%@",timeZoneStr]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"HH:mm"];
    _fTime.text = [dateFormatter stringFromDate:_timePicker.date];
}


/*
 * @Method Name : updateStartTimeOfCallTextField
 * @purpose     : Method used to update start Time
 * @parameters  : nil
 */
- (void)updateStartTimeOfCallTextField{
    
    NSDateComponents *componentsStartDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:_timePicker.date];
    NSDateComponents *componentsSelectedDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:_datePicker.date];
    
    if (componentsStartDate.day > componentsSelectedDate.day){
        NSDateFormatter *dateFormatterTemp = [[NSDateFormatter alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[NSString stringWithFormat:@"%@",timeZoneStr]];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatterTemp setCalendar:calendar];
        [dateFormatterTemp setTimeZone:timeZone];
        [dateFormatterTemp setLocale:locale];
        
        [dateFormatterTemp setDateFormat:@"MM/dd/yyyy"];
        
        _fDate.text = [dateFormatterTemp stringFromDate:_timePicker.date];
        
//        NSLog(@"componentsStartDate %zd",componentsStartDate.day);
//        NSLog(@"componentsSelectedDate %zd",componentsSelectedDate.day);
        
    }
    
    [self updateStartTimeWithCurrentData];
}

- (void)updateEndTimeAndRemoveDatePickerView{
    //Date picker done button click event
    [self updateDateOfCallTextField];
    [_fDate resignFirstResponder];
}

# pragma mark - UITextFieldDelegate Methods

/*
 * @Method Name : textFieldShouldBeginEditing:(UITextField *)textField [UITextFieldDelegate]
 * @purpose     : Method used to 'set time zone' + 'set schedule call type' +'set start time' +'set end time' + 'Repeat schedule'
 * @parameters  : (UITextField *)textField
 */
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    if (textField == _fTimeZone) {
        //set time zone
        _timeZoneListView = [YuViTimeSelectTimeZoneView initWithNib];
        _timeZoneListView.index_defaultTimeZone = _index_defaultTimeZone;
        _timeZoneListView.timeZones = _timeZones;
        _timeZoneListView.timeZoneData = _timeZoneData;
        [_timeZoneListView initializeTimeZones];
        _timeZoneListView.frame = CGRectMake(0, 0, self.view.frame.size.width - 30, self.view.frame.size.height - 40);
        _timeZoneListView.delegate = self;
        _timeZoneListView.layer.cornerRadius = 4.0;
        _timeZoneListView.layer.borderWidth = 1.0;
        _timeZoneListView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor colorWithRed:24.0/255
                                                                                              green:44.0/255
                                                                                               blue:93.0/255
                                                                                              alpha:1.0]);
        [_timeZoneListView showSelectedDefaultTimeZone];
        
        _selectTimeZonePopUp = [KLCPopup popupWithContentView:_timeZoneListView
                                                     showType:KLCPopupShowTypeGrowIn
                                                  dismissType:KLCPopupDismissTypeGrowOut
                                                     maskType:KLCPopupMaskTypeDimmed
                                     dismissOnBackgroundTouch:true
                                        dismissOnContentTouch:false];
        [_selectTimeZonePopUp showAtCenter:[UIApplication sharedApplication].keyWindow.center
                                    inView:[UIApplication sharedApplication].keyWindow];
        return false;
    }
    else if (textField == _fTypedaily) {
        //set schedule call type
        UIAlertController *repeatTypeAlert = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *dailyAction = [UIAlertAction actionWithTitle:@"Daily"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                _callRepeatTypeString = @"EVERY_DAY";
                                                                [self setAttributedTextOnTxtTypeDaily:kDaily];
                                                            }];
        UIAlertAction *weeklyAction = [UIAlertAction actionWithTitle:@"Weekly"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 _callRepeatTypeString = @"EVERY_WEEK";
                                                                  [self setAttributedTextOnTxtTypeDaily:kWeekly];
                                                             }];
        UIAlertAction *monthlyAction = [UIAlertAction actionWithTitle:@"Monthly"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  _callRepeatTypeString = @"EVERY_MONTH";
                                                                   [self setAttributedTextOnTxtTypeDaily:kMonthly];
                                                              }];
        UIAlertAction *yearlyAction = [UIAlertAction actionWithTitle:@"Yearly"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 _callRepeatTypeString = @"EVERY_YEAR";
                                                                  [self setAttributedTextOnTxtTypeDaily:kYearly];
                                                             }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [repeatTypeAlert addAction:dailyAction];
        [repeatTypeAlert addAction:weeklyAction];
        [repeatTypeAlert addAction:monthlyAction];
        [repeatTypeAlert addAction:yearlyAction];
        [repeatTypeAlert addAction:cancelAction];
        

        [self presentViewController:repeatTypeAlert
                           animated:true
                         completion:nil];
        return false;
    }else if ([_fTime isEqual:textField]){
       // set start time
        //Start time
        if (_fEndTime.text.length){
            //Set
//            _timePicker.maximumDate = [endTimePicker.date dateByAddingTimeInterval:-kTimeDifferenceMarginStartAndEndCall];
            _fEndTime.text = @"";
        }else{
            //Set minimum date if current date is selected
            
        }
        
    }else if ([_fEndTime isEqual:textField]){
        //End time
        if (_fTime.text.length) {
             endTimePicker.minimumDate = [_timePicker.date dateByAddingTimeInterval:kTimeDifferenceMarginStartAndEndCall];
        }else{
              NSDate* newDate = [[NSDate date] dateByAddingTimeInterval:kTimeDifferenceMarginStartAndEndCall];
              endTimePicker.minimumDate = newDate;
        }
        
    }else if ([textField isEqual:_noRepeatReminderInMinutes] || [textField isEqual:_fRiminderInMinute]){
        //Show dropdown of alert before in minutes
        [self setAlertBeforeMinutesFromTextField:textField];

        return false;
        
    }
    return true;
    
}


- (void)setAlertBeforeMinutesFromTextField:(UITextField*)textField{
    
    
   int minutesBetween = [self differenceBetweenStartTimeAndCurrentTime];
    
    if(!_fTime.text.length) //Show alert if no time is selected
        minutesBetween = -1;
    
    UIAlertController *repeatTypeAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   
    
    NSInteger tagIndex = 0;
    if (minutesBetween<kMinimumTimeDifferenceMargin && _fTime.text.length){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid start time" message:@"Start time and current time difference should not be less than 7 minutes." preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        // Present alert.
        [self presentViewController:alertController animated:YES completion:nil];
       
        return;
    }
    
    if (minutesBetween>[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *fiveMinutesBeforeAction = [UIAlertAction actionWithTitle:@"5 minutes before"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                                            textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                            textField.tag = tagIndex; //This tag helps to fetch data while calling API
                                                                        }];
         [repeatTypeAlert addAction:fiveMinutesBeforeAction];
    }else{
        
        UIAlertAction *atCallTimeAction = [UIAlertAction actionWithTitle:@"Please select schedule call start date and time first"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
        [repeatTypeAlert addAction:atCallTimeAction];
    }
    tagIndex = 1;
    if (minutesBetween>=[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *fifteenMinutesBeforeAction = [UIAlertAction actionWithTitle:@"15 minutes before"
                                                                             style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                                               textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                               textField.tag = tagIndex;//This tag helps to fetch data while calling API
                                                                           }];
        [repeatTypeAlert addAction:fifteenMinutesBeforeAction];
    }
    
     tagIndex = 2;
    if (minutesBetween>=[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *thirtyMinutesBeforeAction = [UIAlertAction actionWithTitle:@"30 minutes before"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                                              textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                              textField.tag = tagIndex;//This tag helps to fetch data while calling API
                                                                          }];
        [repeatTypeAlert addAction:thirtyMinutesBeforeAction];
    }
    
     tagIndex = 3;
    if (minutesBetween>=[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *oneHourBeforeAction = [UIAlertAction actionWithTitle:@"1 hour before"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                        textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                        textField.tag = tagIndex;//This tag helps to fetch data while calling API
                                                                    }];
         [repeatTypeAlert addAction:oneHourBeforeAction];
    }
    
     tagIndex = 4;
    if (minutesBetween>=[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *twoHoursBeforeAction = [UIAlertAction actionWithTitle:@"2 hours before"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                         textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                         textField.tag = tagIndex;//This tag helps to fetch data while calling API
                                                                     }];
         [repeatTypeAlert addAction:twoHoursBeforeAction];
    }
    
     tagIndex = 5;
    if (minutesBetween>=[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *oneDayBeforeAction = [UIAlertAction actionWithTitle:@"1 day before"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                                       textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                       textField.tag = tagIndex;//This tag helps to fetch data while calling API
                                                                   }];
         [repeatTypeAlert addAction:oneDayBeforeAction];
    }
    
     tagIndex = 6;
    if (minutesBetween>=[arrAlertBeforeMinutes[tagIndex] intValue]) {
        UIAlertAction *oneWeekBeforeAction = [UIAlertAction actionWithTitle:@"1 week before"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                        textField.text = [self timeFormattedWithMinutes:[arrAlertBeforeMinutes[tagIndex] intValue]];
                                                                        textField.tag = tagIndex;//This tag helps to fetch data while calling API
                                                                    }];
        [repeatTypeAlert addAction:oneWeekBeforeAction];
    }
    
   
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [repeatTypeAlert addAction:cancelAction];
    
    [self presentViewController:repeatTypeAlert  animated:true  completion:nil];
}


#pragma mark - YuViTimeSelectTimeZoneViewDelegate Methods

- (void)didSelectTimeZone:(NSArray *)selectedTimeZoneArray{
   // NSLog(@"Selected Time Zone: %@", selectedTimeZoneArray);
    _fTimeZone.text = [selectedTimeZoneArray lastObject];
    _selectedTimeZone = selectedTimeZoneArray;
    [_selectTimeZonePopUp dismiss:true];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",_selectedTimeZone.firstObject];
    NSArray *arrFilter = [_timeZones filteredArrayUsingPredicate:predicate];
    
    if (arrFilter.count)
        _index_defaultTimeZone = [_timeZones indexOfObject:arrFilter.firstObject];
    else
        _index_defaultTimeZone = 0;
    
    timeZone = arrFilter.firstObject;
    
    NSArray *comp = [timeZone componentsSeparatedByString:@" "];
    
    NSString *key = comp[1];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                    @"ActiveSupport_to_iOS_timezones" ofType:@"plist"];
    
    // Build the array from the plist
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSDictionary *TimeZones = [dict valueForKey:@"TimeZones"];
    
    //NSLog(@"%@",TimeZones);
    
    NSString *timeZoneName = TimeZones[key];
    
    timeZoneStr = TimeZones[key];
    
    NSDate *dateNow = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:dateNow];

     startDate = [self getCustomFormateString:dateStr withTimeZone:timeZoneName];
     
     [_datePicker setDate:startDate];
     _datePicker.minimumDate = startDate;
     NSDate *maxDate = [startDate dateByAddingTimeInterval:kMaximumDate];
     _datePicker.maximumDate = maxDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[NSString stringWithFormat:@"%@",timeZoneStr]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    _fDate.text = [dateFormatter stringFromDate:_datePicker.date];
    
    NSTimeInterval secondsBetween = [startDate timeIntervalSinceDate:dateNow];
    
    if (secondsBetween<0) {
        secondsBetween = -secondsBetween;
    }
    
    [_timePicker setDate:[[NSDate date] dateByAddingTimeInterval:(secondsBetween+kMinimumStartTime)]];
    _timePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:(secondsBetween+kMinimumStartTime)];
    
    _timePicker.tintColor = [UIColor whiteColor];
    
    [_timePicker setDatePickerMode:UIDatePickerModeTime];
    
    NSLog(@"%@",_timePicker.minimumDate);
}

-(NSDate *)getCustomFormateString:(NSString *)localDateStr withTimeZone:(NSString *)timeZoneName
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[NSString stringWithFormat:@"%@",timeZoneName]];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   // NSInteger seconds = [timeZone secondsFromGMTForDate: [NSDate date]];
    NSDate *dateNow = [dateFormatter dateFromString:localDateStr];
    
    return dateNow;
}

- (int)differenceBetweenStartTimeAndCurrentTime {
    //Comapare date time margin wrt to time zone
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: _datePicker.date];
    NSArray *arrComponent = [_fTime.text componentsSeparatedByString:@":"];
    [components setHour: [arrComponent.firstObject integerValue]];
    [components setMinute: [arrComponent.lastObject integerValue]];
    [components setSecond: 0];
    NSDate *dateSelected = [gregorian dateFromComponents: components];
    
    // Use the user's current calendar and time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    NSDate *dateCurrent = [NSDate date];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:dateCurrent];
    NSDate *dateCurrentDate = [dateFormatter dateFromString:dateString];
    
    int minutesBetween = [dateSelected timeIntervalSinceDate:dateCurrentDate]/60;
    NSLog(@"minutes difference Between %d",minutesBetween);

    return minutesBetween;
}

- (NSString *)timeFormattedWithMinutes:(int)totalMinutes
{
    
    int minutes = totalMinutes % 60;
    int hours = (totalMinutes/60) % 24;
    int days = (totalMinutes/1440);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",days,hours,minutes];
}

- (NSString *)timeFormattedToMinutes:(int)totalSeconds
{
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d",hours, minutes];
}

- (void)setAttributedTextOnTxtTypeDaily:(NSString *)strText{
    
    UIColor *color = kYuWeeThemeColor;
    NSString *string = @"Repeat Type :\t";
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    NSMutableAttributedString *strMutableAttributed = [[NSMutableAttributedString alloc]initWithAttributedString:attrStr];
    
    UIColor *colorText = [UIColor blackColor];
    NSDictionary *attrsText = @{ NSForegroundColorAttributeName : colorText };
    NSAttributedString *attrStrText = [[NSAttributedString alloc] initWithString:strText attributes:attrsText];
    [strMutableAttributed appendAttributedString:attrStrText];
    
    _fTypedaily.attributedText = strMutableAttributed;
}

- (void)setDefaultTimeZone{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"timezone" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    _timeZoneData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    _timeZones = [[NSMutableArray alloc] init];
    
    for (NSArray *timeZone in _timeZoneData) {
        [_timeZones addObject:[timeZone lastObject]];
    }
    
    //Get local time zone to make it selected by default
    NSString *strLocalTimeZone = [NSTimeZone localTimeZone].name;
    NSArray *arrLocalZone = [strLocalTimeZone componentsSeparatedByString:@"/"];
    NSString *strLocalZoneIdentifier = arrLocalZone.lastObject;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",strLocalZoneIdentifier];
    NSArray *arrFilter = [_timeZones filteredArrayUsingPredicate:predicate];
    if (arrFilter.count) {
        _fTimeZone.text = arrFilter.firstObject;
        _index_defaultTimeZone = [_timeZones indexOfObject:arrFilter.firstObject]+1;
        _selectedTimeZone = _timeZoneData[_index_defaultTimeZone];
    }else{
        
        _index_defaultTimeZone = 0;
    }
}

- (BOOL)processValidateEmails:(NSString *)enteredEmails{
    NSArray *items = [enteredEmails componentsSeparatedByString:@","];
    
    if (items.count == 1) {
        NSString *email = (NSString *) [items objectAtIndex:0];
        if (![self isStringIsValidEmail: email]) {
            return NO;
        }
    } else {
        for (int i = 0; i < items.count; i++) {
            NSString *email = (NSString *) [items objectAtIndex:i];
            if (![self isStringIsValidEmail: email]) {
                return NO;
            }
        }
    }
    return YES;
}

-(NSArray*)getValidEmails:(NSString *)enteredEmails{
    NSArray *items = [enteredEmails componentsSeparatedByString:@","];
    
    NSMutableArray *validEmail = [[NSMutableArray alloc] init];
    if (items.count == 1) {
        NSString *email = (NSString *) [items objectAtIndex:0];
        [validEmail addObject:email];
    } else {
        for (int i = 0; i < items.count; i++) {
            NSString *email = (NSString *) [items objectAtIndex:i];
            [validEmail addObject:email];
        }
    }
    return validEmail;
}

-(BOOL)isStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

- (void)showAlert:(NSString*)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

@end
