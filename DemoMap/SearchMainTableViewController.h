//
//  SearchMainTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/16/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseTableViewController.h"
#import "Line.h"
#import "Direction.h"
#import "Station.h"

@interface SearchMainTableViewController : SearchBaseTableViewController
@property (nonatomic, copy) NSArray *stations;

@property NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *lines;
@property (strong, nonatomic) NSArray *directionArray;
@property (strong, nonatomic) NSMutableArray *stationArray;
@property (strong, nonatomic) NSMutableArray *stationNameArray;
@property (strong, nonatomic) NSArray *resultsArray;


@end
