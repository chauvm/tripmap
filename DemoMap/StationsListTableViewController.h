//
//  StationsListTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 5/10/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Direction.h"

@interface StationsListTableViewController : UITableViewController
@property BOOL inbound;
@property (nonatomic, strong) NSMutableArray *indexesArray;
@property (strong, nonatomic) Direction *direction;
@property NSArray *stationArray;
@property NSManagedObjectContext *managedObjectContext;

@end
