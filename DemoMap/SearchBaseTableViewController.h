//
//  SearchBaseTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/16/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"
extern NSString *const kCellIdentifier;

@interface SearchBaseTableViewController : UITableViewController
- (void)configureCell:(UITableViewCell *)cell forStation:(Station *)station;
@property BOOL searchStart;
@property BOOL searchEnd;
@property BOOL wantSelectStation;
@end
