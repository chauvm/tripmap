//
//  DisplayRouteTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/17/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@interface DisplayRouteTableViewController : UITableViewController
@property (strong, nonatomic) Station *startStation;
@property (strong, nonatomic) Station *endStation;
@property (strong, nonatomic) NSArray *stationArray;
@property (strong, nonatomic) NSString *transferStationName;
@property (strong, nonatomic) NSString *instruction;
@property NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

@end
