//
//  LocationViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 5/31/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Location";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.currentStationName resignFirstResponder];
    return YES;
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
//    if ([segue.identifier isEqualToString:@"ShowSearchRoute"]) {
//        UINavigationController *nav = [segue destinationViewController];
//        SearchStationTableViewController *sstvc = (SearchStationTableViewController *) nav.topViewController;
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSString *currentCity = [userDefaults objectForKey:@"CurrentCity"];
//        sstvc.city = currentCity;
//    } else
    if ([segue.identifier isEqualToString:@"ShowSearchStation"]) {
    
    }
}


@end
