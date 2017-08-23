//
//  ContactInfoViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/21/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "ContactInfoViewController.h"

@interface ContactInfoViewController ()

@end
#define CALL 1
NSArray *_telNumbers;
NSArray *_agencyNames;

@implementation ContactInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _telNumbers = @[@"18003926100", @"18776905116", @"14156736864", @"12026377000"];
    _agencyNames = @[@"MBTA, Boston", @"MTA, New York City", @"SFMTA, San Francisco", @"Metro, Washington DC"];
    
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

- (IBAction)callAgency:(UIButton *)sender {
    NSLog(@"Sender tag: %ld", (long)sender.tag);
    NSString *phoneNumber = [_telNumbers objectAtIndex:sender.tag - 1];
    self.currentPhoneNumber = [_telNumbers objectAtIndex:sender.tag - 1];
    NSString *name = [_agencyNames objectAtIndex:sender.tag - 1];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Contact %@ transit agency", name]
                                                    message:[NSString stringWithFormat: @"Do you want to make a phone call to %@", phoneNumber]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Yes, make a call"];
    alert.tag = CALL;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked Cancel");
    }
    else if(alertView.tag == CALL)
    {
        NSString *callString;
        callString = [NSString stringWithFormat:@"tel:%@", self.currentPhoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callString]];
    }
}

@end
