//
//  FavoriteTipsViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/9/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "FavoriteTipsViewController.h"
#import "CategorizedTipsTableTableViewController.h"
#import "TipFormViewController.h"

@interface FavoriteTipsViewController () {
    NSArray *_pickerData;
}
@end

@implementation FavoriteTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.directionName isEqualToString:@"Parent"]) {
        self.title = [NSString stringWithFormat:@"Tips for %@ main station", self.station.name];
    } else {
        self.title = [NSString stringWithFormat:@"Tips for %@ towards %@", self.station.name, self.end];
    }
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    tlabel.text=self.navigationItem.title;
    tlabel.adjustsFontSizeToFitWidth=YES;
    tlabel.numberOfLines = 0;
    tlabel.lineBreakMode = NSLineBreakByWordWrapping;
    tlabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
    [tlabel setAutoresizesSubviews:YES];
    self.navigationItem.titleView=tlabel;

    
    
    _pickerData = @[ @[@"favored", @"navigation"],
                     @[@"neutral", @"warning"],
                     @[@"snubbed", @"recommendation"],
                     @[@"uncategorized"]
                     ];
    // Connect data
    self.tagPicker.dataSource = self;
    self.tagPicker.delegate = self;
    self.tagPicker.isAccessibilityElement = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 3;
    } else {
        return 4;
    }
//    return _pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 1 && row == 3) {
        return _pickerData[3][0];
    } else {
        return _pickerData[row][component];
    }
}

- (NSString *)getDirectionNameOnly:(NSString*)directionName {
    if ([directionName rangeOfString:@"weekend"].location == NSNotFound) {
        if ([directionName rangeOfString:@"weekdays"].location == NSNotFound) {
            return directionName;
        } else {
            return [self removeScheduleType:@"weekdays" from:directionName];
        }
    } else {
        return [self removeScheduleType:@"weekend" from:directionName];
    }
}

- (NSString *)removeScheduleType:(NSString*)type
                            from:(NSString*)directionName {
    NSArray *components = [directionName componentsSeparatedByString:@" - "];
    NSMutableArray *componentsWithoutType = [NSMutableArray arrayWithArray:components];
    [componentsWithoutType removeObjectAtIndex:[components count] - 1];
    NSString *joinedString = [componentsWithoutType componentsJoinedByString:@""];
    if ([joinedString rangeOfString:type].location == NSNotFound) {
        NSLog(@"remove schedule type successfully: %@", joinedString);
    } else {
        NSLog(@"schedule type remained: %@", joinedString);
    }
    return joinedString;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ShowTipForm"]) {
        // show tip form
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        TipFormViewController* tfvc = (TipFormViewController*)[navController topViewController];
        tfvc.currentDirectionName = [self getDirectionNameOnly:self.directionName];
        tfvc.station = self.station;
    } else {
        // show tips by category
        NSInteger type_ind = [self.tagPicker selectedRowInComponent:0];
        NSInteger category_ind = [self.tagPicker selectedRowInComponent:1];
        NSString *type = _pickerData[type_ind][0];
        
        NSString *category;
        if (category_ind == 3) {
            category = _pickerData[3][0];
        } else {
            category = _pickerData[category_ind][1];
        }
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        CategorizedTipsTableTableViewController* cttvc = (CategorizedTipsTableTableViewController*)[navController topViewController];
        cttvc.type = type;
        cttvc.category = category;
        cttvc.stationName = [self.directionName isEqualToString:@"Parent"] ? self.station.parent_station : self.station.name;
        cttvc.stationChildName = self.station.name;
        cttvc.currentDirectionName = [self getDirectionNameOnly:self.directionName];
    }
}


@end
