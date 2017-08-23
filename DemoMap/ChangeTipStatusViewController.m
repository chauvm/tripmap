//
//  ChangeTipStatusViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/14/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "ChangeTipStatusViewController.h"
#define FLAG_TIP 1

@interface ChangeTipStatusViewController () {
    NSArray *_pickerDataArray;
}
@end

@implementation ChangeTipStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pickerDataArray = @[@"favored", @"neutral", @"snubbed", @"flagged"];
    
    // Connect data
//    self.statusPicker.dataSource = self;
    self.statusPicker.delegate = self;
    self.statusPicker.isAccessibilityElement = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerDataArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerDataArray[row];
}

- (IBAction)changeStatus:(id)sender {
    NSString *curTag = [self pickerView:self.statusPicker titleForRow:[self.statusPicker selectedRowInComponent:0] forComponent:0];
    if ([curTag isEqual: @"flagged"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to flag this tip as inappropriate?"
                                                        message:@"This tip will be sent to the developers for moderation, and will be moved to your snubbed tips list."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Yes, flag tip"];
        alert.tag = FLAG_TIP;
        [alert show];
    } else {
        [self submitTipStatus];
    }

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked Cancel");
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"You have clicked Yes, flag tip");
        [self submitTipStatus];
    }
}

- (void)submitTipStatus{
    NSString *curTag = [self pickerView:self.statusPicker titleForRow:[self.statusPicker selectedRowInComponent:0] forComponent:0];
    
    __block PFObject *tipStatusObject;
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"tipStatusObject"];
    [query whereKey:@"username" equalTo:currentUser.username];
    [query whereKey:@"tip_id" equalTo:self.currentTip.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 1) {
                NSLog(@"Warning: More than one possible tipStatusObject");
            }
            
            if ([objects count] == 0) {
                tipStatusObject = [PFObject objectWithClassName:@"tipStatusObject"];
                tipStatusObject[@"username"] = currentUser.username;
                tipStatusObject[@"tip_id"] = self.currentTip.objectId;
            } else {
                tipStatusObject = [objects objectAtIndex:0];
            }
            tipStatusObject[@"favored"] = @NO;
            tipStatusObject[@"neutral"] = @NO;
            tipStatusObject[@"snubbed"] = @NO;
            tipStatusObject[@"flagged"] = @NO;
            tipStatusObject[curTag] = @YES;
            if ([curTag isEqual: @"flagged"]) {
                tipStatusObject[@"snubbed"] = @YES;
            }
            [tipStatusObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // The object has been saved.
                    // alert and back to Categorized Tips view
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Tip status has been changed. You are going back to Categorized Tips screen." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                    [self performSegueWithIdentifier:@"unwindFromTipStatusIdentifier" sender:self];
                } else {
                    // There was a problem, check error.description
                    [[[UIAlertView alloc] initWithTitle:nil message:@"There was a problem saving tip status. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                }
            }];
        } else {
            NSLog(@"Parse query failure");
        }
    }];
}

@end
