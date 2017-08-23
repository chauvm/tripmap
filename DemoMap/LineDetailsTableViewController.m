//
//  LineDetailsTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 5/11/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "LineDetailsTableViewController.h"
#import "Line.h"
#import "Direction.h"
#import "AppDelegate.h"
#import "StationsListTableViewController.h"

@interface LineDetailsTableViewController ()
@end

static NSString *directionsArraytKey = @"DirectionsArrayKey";
UIColor *lineColor;
@implementation LineDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = self.lineItem.route_name;
    
    lineColor = [self getLineColor:self.lineItem];
    
    self.directionArray = [[NSArray alloc] init];
    [self loadDirectionsArray];
}

- (UIColor*)getLineColor:(Line*)line {
    NSString *stringColor;
    if (line.route_color) {
        stringColor = line.route_color;
    } else {
        stringColor = @"B2B2B2";
    }
    NSUInteger red, green, blue;
    sscanf([stringColor UTF8String], "%02X%02X%02X", &red, &green, &blue);
    UIColor *color = [[UIColor alloc] init];
    color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:0.05];
    return color;
}

// lineArray: ["Alewife-Braintree", "Alewife-Ashmont"}
- (void)loadDirectionsArray {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    self.directionArray = [self.lineItem.directions sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.directionArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LineDirection" forIndexPath:indexPath];
    
    // Configure the cell...
    Direction *line = [self.directionArray objectAtIndex:indexPath.row];
    cell.textLabel.text = line.name;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    [cell setAccessibilityLabel:[line.name accessibilityLabel]];

    cell.backgroundColor = lineColor;
    
    return cell;
}

#pragma select line direction to see list of stations

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Direction *tappedItem = [self.directionArray objectAtIndex:indexPath.row];

    StationsListTableViewController *sltvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Station_List"];
    sltvc.direction = tappedItem;
    [self.navigationController pushViewController:sltvc animated:YES];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
