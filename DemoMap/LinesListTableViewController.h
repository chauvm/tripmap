//
//  LinesListTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 5/11/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"
#import "Station.h"

@interface LinesListTableViewController : UITableViewController
@property Station *transferCheckedStation;
@property NSString *city;
@property NSManagedObjectContext *managedObjectContext;
@end
