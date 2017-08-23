//
//  LinesListTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 5/11/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "LinesListTableViewController.h"
#import "LineDetailsTableViewController.h"
#import "Line.h"
#import "AppDelegate.h"

@interface LinesListTableViewController ()

@end
static NSString *linesArraytKey = @"LinesArrayKey";
NSArray *lines;
NSArray *transferLines;

@implementation LinesListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.transferCheckedStation == nil) {
        self.navigationItem.title = @"Subway List";
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"Lines from %@", self.transferCheckedStation.name];
    }
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self loadLinesArray];
    
}

- (void)loadLinesArray {
    if (self.transferCheckedStation != nil) {
        [self loadTransferLinesArray];
    } else if (self.city != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Line"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"state == %@", self.city];
        NSSortDescriptor *alphabet_route_id = [[NSSortDescriptor alloc] initWithKey:@"route_id" ascending:YES];

        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:alphabet_route_id]];
        NSError *requestError = nil;
        lines = [[NSArray alloc] init];
        lines = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
        if ([lines count] > 0) {
            NSLog(@"Get some lines in Lines List: %lu", (unsigned long)[lines count]);
        } else {
            NSLog(@"No line found in Lines List");
        }
    }
}


- (void)loadTransferLinesArray {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Line"];
    NSSortDescriptor *alphabet_route_id = [[NSSortDescriptor alloc] initWithKey:@"route_id" ascending:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCity = [userDefaults objectForKey:@"CurrentCity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(route_id IN %@) AND state == %@", [self getLinesFromStation:self.transferCheckedStation], currentCity];

    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:alphabet_route_id]];
    NSError *requestError = nil;
    transferLines = [[NSArray alloc] init];
    transferLines = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    if ([transferLines count] > 0) {
        NSLog(@"Get some lines in Transfer Lines List: %lu", (unsigned long)[transferLines count]);
    } else {
        NSLog(@"No line found in Transfer Lines List");
    }
}

- (NSArray *)getLinesFromStation:(Station*)station {
    NSString *transfer_lines = station.transfer_lines;
    NSArray *transfer_lines_array = [transfer_lines componentsSeparatedByString: @","];
    return transfer_lines_array;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor redColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.transferCheckedStation != nil) {
        return [transferLines count];
    }
    return [lines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LineListCell" forIndexPath:indexPath];
    
    // Configure the cell...

    NSArray *existing_lines;
    if (self.transferCheckedStation != nil) {
        existing_lines = transferLines;
    } else {
        existing_lines = lines;
    }
    Line *line = [existing_lines objectAtIndex:indexPath.row];
    if ([line.state isEqualToString:@"New York City, New York, USA"] ||
        [line.state isEqualToString:@"San Francisco, California, USA"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", line.route_name, line.route_long_name];
    } else {
        cell.textLabel.text = line.route_name;
    }
    
    [cell setAccessibilityLabel:[line.route_name accessibilityLabel]];
    
    cell.backgroundColor = [self getLineColor:line];

    return cell;
}

#pragma select line color to see list of directions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *existing_lines;
    if (self.transferCheckedStation != nil) {
        //        line = [transferLines objectAtIndex:indexPath.row];
        existing_lines = transferLines;
    } else {
        //        line = [lines objectAtIndex:indexPath.row];
        existing_lines = lines;
    }
    Line *tappedItem = [existing_lines objectAtIndex:indexPath.row];
    LineDetailsTableViewController *ldtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Line_Detail"];
    ldtvc.lineItem = tappedItem;
    
    [self.navigationController pushViewController:ldtvc animated:YES];
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
