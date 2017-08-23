//
//  TipFormViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/11/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"
#import "Direction.h"

@interface TipFormViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) Station* station;
@property (strong, nonatomic) NSString *currentDirectionName;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;


@property (weak, nonatomic) IBOutlet UIPickerView *pickerData;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
- (IBAction)submitButtonTapped:(id)sender;

@end
