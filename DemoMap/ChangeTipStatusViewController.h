//
//  ChangeTipStatusViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/14/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChangeTipStatusViewController : UIViewController <UIPickerViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *statusPicker;
- (IBAction)changeStatus:(id)sender;
@property (strong, nonatomic) PFObject *currentTip;
@end
