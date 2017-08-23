//
//  LineDetailsTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 5/11/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@interface LineDetailsTableViewController : UITableViewController
@property NSArray *directionArray;
@property (strong, nonatomic) Line *lineItem;
@end
