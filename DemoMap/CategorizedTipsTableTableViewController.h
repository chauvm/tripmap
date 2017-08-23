//
//  CategorizedTipsTableTableViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/13/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
@interface CategorizedTipsTableTableViewController : PFQueryTableViewController
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *stationName;
@property (strong, nonatomic) NSString *stationChildName;
@property (strong, nonatomic) NSString *currentDirectionName;
- (IBAction)unwindFromTipStatus:(UIStoryboardSegue *)segue;


@end
