//
//  CityTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/9/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "CityTableViewController.h"
#import "Line.h"
#import "LinesListTableViewController.h"

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface CityTableViewController ()

@end

NSArray *cities;

@implementation CityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Cities";
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    if (self.managedObjectContext == nil) {
        NSLog(@"managedObjectContext is still nil");
    }
    
    cities = [[NSArray alloc] init];
    
    [self loadCitiesArray];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCitiesArray {
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Line" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"state"]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil) {
        // Handle the error.
        NSLog(@"No city/state found in City Table View: %@", results);
    } else {
        cities = [results valueForKey:@"state"];
        if ([cities count] > 0) {
            NSLog(@"Get some cities/states in City Table View: %@", cities);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [cities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *city = [cities objectAtIndex:indexPath.row];
    //NSLog(city.);
    cell.textLabel.text = city;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [AppDelegate lightGrayColor];
    }
    else
    {
        cell.backgroundColor = [AppDelegate lightYellowColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    LineItem *tappedItem = [self.linesArray objectAtIndex:indexPath.row];
    NSString *tappedItem = [cities objectAtIndex:indexPath.row];
    LinesListTableViewController *lltvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Lines_List"];
    lltvc.city = tappedItem;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:tappedItem forKey:@"CurrentCity"];
    [userDefaults synchronize];
    [self.navigationController pushViewController:lltvc animated:YES];
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
