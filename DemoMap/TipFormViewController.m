//
//  TipFormViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/11/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "TipFormViewController.h"
#import "StationDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <Parse/Parse.h>

@interface TipFormViewController () {
    NSArray *_pickerDataArray;
#define CHANGE_TAG 1

}
@end

@implementation TipFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSString *title;
    if ([self.currentDirectionName isEqualToString:@"Parent"]) {
        title = [NSString stringWithFormat:@"Leave a tip for %@ main station", self.station.name];
    } else {
        title = [NSString stringWithFormat:@"Leave a tip for %@ station, %@", self.station.name, self.currentDirectionName];
    }
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    tlabel.text= title;
    tlabel.numberOfLines = 0;
    tlabel.lineBreakMode = NSLineBreakByWordWrapping;
    tlabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
    [tlabel setAutoresizesSubviews:YES];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    [self.instructionLabel setText:@"Please enter a tip, and select a category"];
    
    _pickerDataArray = @[@"uncategorized", @"navigation", @"warning", @"recommendation"];
    
    // Connect data
    self.pickerData.dataSource = self;
    self.pickerData.delegate = self;
    self.pickerData.isAccessibilityElement = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerDataArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerDataArray[row];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.contentTextField isFirstResponder] && [touch view] != self.contentTextField) {
        [self.contentTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)dismissKeyboard:(id)sender{
    [self.contentTextField resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (IBAction)submitButtonTapped:(id)sender {
    NSLog(@"Do validation here");
    NSString *warnMsg = [self validateTips];
    if (warnMsg == nil) {
        NSLog(@"Can save tip");
        NSString *curTag = [self pickerView:self.pickerData titleForRow:[self.pickerData selectedRowInComponent:0] forComponent:0];
        NSLog(@"curTag: %@", curTag);
        if ([curTag isEqual: @"uncategorized"]) {
            NSLog(@"uncategorized tag detected");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have tagged this tip as Uncategorized"
                                                            message:@"Do you want to change the tag?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No, submit tip"
                                                  otherButtonTitles:nil];
            [alert addButtonWithTitle:@"Yes, edit tip"];
            alert.tag = CHANGE_TAG;
            [alert show];
        } else {
            [self submitTip];
        }
    } else {
        NSLog(@"Error: %@", warnMsg);
        [[[UIAlertView alloc] initWithTitle:nil message:warnMsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }

}

- (void)submitTip{
    PFUser *currentUser = [PFUser currentUser];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCity = [userDefaults objectForKey:@"CurrentCity"];
    
    
    PFObject *tipObject = [PFObject objectWithClassName:@"tipObject"];
    tipObject[@"username"] = currentUser.username;
    
    tipObject[@"content"] = self.contentTextField.text;
    
    
    tipObject[@"navigation"] = @NO;
    tipObject[@"warning"] = @NO;
    tipObject[@"recommendation"] = @NO;
    tipObject[@"uncategorized"] = @NO;
    
    NSString *curTag = [self pickerView:self.pickerData titleForRow:[self.pickerData selectedRowInComponent:0] forComponent:0];
    tipObject[curTag] = @YES;
    
    
    if ([self.currentDirectionName isEqualToString:@"Parent"]) {
        tipObject[@"stationName"] = self.station.parent_station;
    } else {
        tipObject[@"stationName"] = self.station.name;
    }
    
    tipObject[@"direction"] = self.currentDirectionName;
    
    tipObject[@"city"] = currentCity;
    
    tipObject[@"reported"] = @NO;
    
    [tipObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.

            // new tip is favored by owner
            PFObject *tipStatusObject = [PFObject objectWithClassName:@"tipStatusObject"];
            tipStatusObject[@"username"] = currentUser.username;
            tipStatusObject[@"tip_id"] = tipObject.objectId;
            tipStatusObject[@"favored"] = @YES;
            tipStatusObject[@"neutral"] = @NO;
            tipStatusObject[@"snubbed"] = @NO;
            tipStatusObject[@"flagged"] = @NO;
            [tipStatusObject saveInBackgroundWithBlock:^(BOOL statusSucceeded, NSError *statusError) {
                if (statusSucceeded) {
                    // alert and back to station details
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Your tip has been submitted and can be found in your favored list. You are going back to see station details." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];

                } else {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Your tip has been submitted and but failed to move to your favored list. You can favor the tip by changing its status later. You are going back to see station details." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                }
                [self performSegueWithIdentifier:@"unwindAndSaveTipIdentifier" sender:self];
            }];
        } else {
            // There was a problem, check error.description
            [[[UIAlertView alloc] initWithTitle:nil message:@"There was a problem saving your tip. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
    }];
    
    
 
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked No, submit tip");
        [self submitTip];
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"You have clicked Yes, edit tip");
    }
}

- (NSString*)validateTips {
    NSString *warnMsg;
    if ([[self.contentTextField text] length] > 0) {
        NSLog(@"Valid, can save");
    } else {
        warnMsg = @"Please enter your tip in tip content text field";
    }
    return warnMsg;
}


@end
