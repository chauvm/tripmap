//
//  SearchResultsTableController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/16/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseTableViewController.h"

@interface SearchResultsTableController : SearchBaseTableViewController
@property (nonatomic, strong) NSArray *filteredStations;
@property BOOL wantSelectStation;

@end
