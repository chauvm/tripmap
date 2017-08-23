//
//  ChooseStationsViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/17/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@interface ChooseStationsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *chooseStart;
@property (weak, nonatomic) IBOutlet UIButton *chooseEnd;
@property (strong, nonatomic) Station *startStation;
@property (strong, nonatomic) Station *endStation;
@property BOOL isSelectingStart;
@property (weak, nonatomic) IBOutlet UIButton *getRouteButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

- (IBAction)unwindAndSelectStation:(UIStoryboardSegue *)segue;
@end
