//
//  ChooseStationsViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/17/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "ChooseStationsViewController.h"
#import "SearchMainTableViewController.h"
#import "DisplayRouteTableViewController.h"

@interface ChooseStationsViewController ()

@end

@implementation ChooseStationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Find a route";
    if (self.startStation == nil && self.endStation == nil) {
        [self.getRouteButton setHidden:YES];
    }
    self.instructionLabel.text = @"Please select start and end station using the two buttons below. You can tap again on these buttons to re-select stations. A get route button will appear once both stations are selected.";
    
    self.chooseEnd.titleLabel.numberOfLines = 0;
    self.chooseEnd.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.chooseStart.titleLabel.numberOfLines = 0;
    self.chooseStart.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
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

    if ([segue.identifier isEqualToString:@"ShowRouteStartStation"]){
        UINavigationController *nav = [segue destinationViewController];
        SearchMainTableViewController *smtvc = (SearchMainTableViewController *) nav.topViewController;
        smtvc.searchStart = YES;
        smtvc.wantSelectStation = YES;
        
    } else if ([segue.identifier isEqualToString:@"ShowRouteEndStation"]) {
        UINavigationController *nav = [segue destinationViewController];
        SearchMainTableViewController *smtvc = (SearchMainTableViewController *) nav.topViewController;
        smtvc.searchEnd = YES;
        smtvc.wantSelectStation = YES;
    } else if ([segue.identifier isEqualToString:@"ShowRoute"]) {
        UINavigationController *nav = [segue destinationViewController];
        DisplayRouteTableViewController *drtvc = (DisplayRouteTableViewController *) nav.topViewController;
        drtvc.startStation = self.startStation;
        drtvc.endStation = self.endStation;
    }
}

- (IBAction)unwindAndSelectStation:(UIStoryboardSegue *)segue {
    if (self.startStation != nil) {
        [self.chooseStart setTitle:[NSString stringWithFormat:@"Start from: %@, %@", self.startStation.name, [self.startStation valueForKeyPath:@"directionStations.name"]] forState:UIControlStateNormal];
    }
    if (self.endStation != nil) {
        [self.chooseEnd setTitle:[NSString stringWithFormat:@"To: %@, %@", self.endStation.name, [self.endStation valueForKeyPath:@"directionStations.name"]] forState:UIControlStateNormal];
    }
    
    if (self.startStation != nil && self.endStation != nil) {
        [self.getRouteButton setHidden:NO];
    }
}




@end
