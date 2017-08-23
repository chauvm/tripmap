//
//  TipsViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 5/31/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "SettingsViewController.h"
#import "SubclassConfigViewController.h"
#import "TutorialViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Settings";
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"LogOutAction"]) {
        [PFUser logOut];
    } else if ([[segue identifier] isEqualToString:@"ShowTutorialFromSettings"]) {
    }
}


@end
