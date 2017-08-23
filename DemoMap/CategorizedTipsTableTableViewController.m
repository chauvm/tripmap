//
//  CategorizedTipsTableTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/13/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "CategorizedTipsTableTableViewController.h"
#import "ChangeTipStatusViewController.h"
#import "TipDetailsViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <Parse/PFUser.h>
@interface CategorizedTipsTableTableViewController ()

@end

@implementation CategorizedTipsTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"Categorized Tips";
    NSString *title = [NSString stringWithFormat:@"%@, %@ tips for %@", self.type, self.category,self.stationChildName];
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    tlabel.text= title;
    tlabel.numberOfLines = 0;
    tlabel.lineBreakMode = NSLineBreakByWordWrapping;
    tlabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
    [tlabel setAutoresizesSubviews:YES];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return 0;
//}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"tipObject";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"username";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:self.category equalTo:[NSNumber numberWithBool:YES]];
    
    // no need city name for now, stationName and direction are unique enough
    [query whereKey:@"stationName" equalTo:self.stationName];
    [query whereKey:@"direction" equalTo:self.currentDirectionName];
    
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *innerQuery = [PFQuery queryWithClassName:@"tipStatusObject"];
    [innerQuery whereKey:@"username" equalTo:currentUser.username];
    if (![self.type isEqualToString:@"neutral"]) {
        [innerQuery whereKey:self.type equalTo:[NSNumber numberWithBool:YES]];
        [query whereKey:@"objectId" matchesKey:@"tip_id" inQuery:innerQuery];
        
//        [query whereKey:@"objectID" matchesQuery:innerQuery];
    } else {
        // neutral type will show all tips in database, except those in user's tipStatusObject
        // with non-YES neutral field
        [innerQuery whereKey:self.type equalTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"objectId" doesNotMatchKey:@"tip_id" inQuery:innerQuery];
    }

    [query orderByDescending:@"createdAt"];
    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"CategorizedTipCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString *tipContent = [object objectForKey:@"content"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ says: %@", [object objectForKey:@"username"],tipContent];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.numberOfLines = 3;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *btnImg = [UIImage imageNamed:@"tag_72.png"];
    button.frame = CGRectMake(0.0f, 0.0f, 75.0f, 50.0f);
    [button setBackgroundImage:btnImg forState:UIControlStateNormal];
    button.accessibilityLabel = @"Change tip status";
    button.isAccessibilityElement = YES;
    [button addTarget:self action:@selector(changeStatus:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:indexPath.row];
    cell.accessoryView = button;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [AppDelegate lightGrayColor];
    }
    else
    {
        cell.backgroundColor = [AppDelegate lightYellowColor];
    }
    return cell;
}

- (void)changeStatus:(UIButton *)sender {
    PFObject *currentTip = [self.objects objectAtIndex:sender.tag];
    
    ChangeTipStatusViewController *ctsvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Change_Tip_Status"];
    ctsvc.currentTip = currentTip;
    [self.navigationController pushViewController:ctsvc animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check that a new transition has been requested to the DetailViewController and prepares for it
    if ([segue.identifier isEqualToString:@"ShowTipDetails"]){
        
        // Capture the object (e.g. exam) the user has selected from the list
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        // Set destination view controller to DetailViewController to avoid the NavigationViewController in the middle (if you have it embedded into a navigation controller, if not ignore that part)
        UINavigationController *nav = [segue destinationViewController];
        TipDetailsViewController *tdvc = (TipDetailsViewController *) nav.topViewController;
        tdvc.currentTip = object;
        tdvc.stationChildName = self.stationChildName;
    }
}

- (IBAction)unwindFromTipStatus:(UIStoryboardSegue *)segue {
    [self loadObjects];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
