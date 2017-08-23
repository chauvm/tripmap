//
//  StationsListTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 5/10/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "StationsListTableViewController.h"
#import "StationDetailsViewController.h"
#import "LinesListTableViewController.h"
#import "Station.h"
#import "AppDelegate.h"


@interface StationsListTableViewController ()
@property Station *transferCheckedStation;
@end

static NSString *stationsDictionarytKey = @"StationsDictionaryKey";
BOOL reverse = NO;

@implementation StationsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.stationsDictionary = [[NSMutableDictionary alloc] init];
    [self loadStationsDictionary];
    [self getTitle];

}

- (void)getTitle {
    NSString *title;
    if (self.inbound) {
        title = [NSString stringWithFormat:@"%@ TO %@", self.direction.start, self.direction.end];
    } else {
        title = [NSString stringWithFormat:@"%@ TO %@", self.direction.end, self.direction.start];
    }
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    tlabel.text= title;
    tlabel.numberOfLines = 0;
    tlabel.lineBreakMode = NSLineBreakByWordWrapping;
    tlabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
    [tlabel setAutoresizesSubviews:YES];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;

}

// stationsDictionary: {1: "Kendall/MIT, 2: "MGH"}
- (void)loadStationsDictionary {
    self.inbound = YES;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    self.stationArray = [self.direction.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
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
    return [self.stationArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    NSUInteger count = [self.stationArray count];
    NSUInteger ind;
    if (self.inbound) {
        ind = indexPath.row;
    } else {
        ind = count-indexPath.row-1;
    }
    Station *station = (Station *)[self.stationArray objectAtIndex:ind];

    cell.textLabel.text = station.name;
    cell.textLabel.numberOfLines = 2;
    
    if (station.transfer && station.transfer_lines) {
        UIImage *btnImg = [self generateTransferImage:station.transfer_lines];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0.0f, 0.0f, 90.0f, 50.0f);
        [button setBackgroundImage:btnImg forState:UIControlStateNormal];
        button.accessibilityLabel = [NSString stringWithFormat:@"%@ can transfer to line %@", station.name, station.transfer_lines];
        button.isAccessibilityElement = YES;

        
        [button addTarget:self action:@selector(transferStationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.tag = ind;
        cell.accessoryView = button;

    } else {
        UILabel *not_transfer_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 50)];
        not_transfer_label.backgroundColor = cell.backgroundColor;
        [not_transfer_label setFont:[UIFont systemFontOfSize:12]];
        not_transfer_label.textAlignment = NSTextAlignmentCenter;
        not_transfer_label.isAccessibilityElement = YES;
        [not_transfer_label setText:@"Not a transfer"];
        [cell setAccessoryView:not_transfer_label];
    }
    // want indexPath.row - the order in list
    if (self.inbound) {
        [cell.imageView setTag:indexPath.row];
    } else {
        [cell.imageView setTag:count-indexPath.row-1];
    }
    
    [cell setAccessibilityLabel:[station.name accessibilityLabel]];
    return cell;
}

- (UIView*) superviewOfType:(Class)paramSuperviewClass
                    forView:(UIView *)paramView{
    if (paramView.superview != nil) {
        if ([paramView.superview isKindOfClass:paramSuperviewClass]) {
            return paramView.superview;
        } else {
            return [self superviewOfType:paramSuperviewClass forView:paramView.superview];
        }
    }
    return nil;
}

- (UIImage*)generateTransferImage:(NSString*)transfer_lines {
    NSArray *color_array = [self getTransferLineColors:transfer_lines];
    CGSize newSize = CGSizeMake(90.0f, 50.0f);
    float unit_width = 90.0f / [color_array count];
    UIGraphicsBeginImageContext( newSize );
    [color_array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *stringColor;
        if ([object length] > 0) {
            stringColor = object;
        } else {
            // gray color for lines without route_color
            stringColor = @"B2B2B2";
        }
        NSUInteger red, green, blue;
        sscanf([stringColor UTF8String], "%02X%02X%02X", &red, &green, &blue);
        UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:0.8];
        UIImage *image = [self imageWithColor:color];
        
        [image drawInRect:CGRectMake(unit_width * idx,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.8];
        
    }];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (NSArray *)getTransferLineColors:(NSString*)transfer_lines {
    NSArray *transfer_lines_array = [transfer_lines componentsSeparatedByString: @","];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Line"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCity = [userDefaults objectForKey:@"CurrentCity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(route_id IN %@) AND state == %@", transfer_lines_array, currentCity];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setPropertiesToFetch:@[@"route_color"]];
    
    NSError *requestError = nil;
    NSArray *transferLineColors_array = [[NSArray alloc] init];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    transferLineColors_array = [results valueForKey:@"route_color"];
    if ([transferLineColors_array count] > 0) {
    } else {
        NSLog(@"No line color found");
    }
    return transferLineColors_array;
}

- (void)transferStationButtonClicked :(UIButton *)sender {
    __unused UITableViewCell *parentCell = (UITableViewCell *)[self superviewOfType:[UITableViewCell class] forView:sender];
    self.transferCheckedStation = [self.stationArray objectAtIndex:parentCell.tag];
    // Go to LinesListTableViewController
    LinesListTableViewController *lltvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Lines_List"];
    lltvc.transferCheckedStation = self.transferCheckedStation;
    [self.navigationController pushViewController:lltvc animated:YES];
}

-(void)transferStationClicked :(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    self.transferCheckedStation = [self.stationArray objectAtIndex:gesture.view.tag];
    
    // Go to LinesListTableViewController
    LinesListTableViewController *lltvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Lines_List"];
    lltvc.transferCheckedStation = self.transferCheckedStation;
    [self.navigationController pushViewController:lltvc animated:YES];
    
    
}

- (IBAction)reverse:(id)sender {
    self.inbound = !self.inbound;
    [self getTitle];
    [self.tableView reloadData];
}


#pragma select station to see details

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger ind;
    if (self.inbound) {
        ind = indexPath.row;
    } else {
        ind = [self.stationArray count] - indexPath.row - 1;
    }
    Station *tappedItem = (Station *)[self.stationArray objectAtIndex:ind];
    StationDetailsViewController *sdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Station_Detail"];
    sdvc.station = tappedItem;
    sdvc.currentDirection = self.direction;
    [self.navigationController pushViewController:sdvc animated:YES];
}


// unused
//- (void)tableView:(UITableView *)tableView accessoryTypeTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"Detail disclosure button tapped");
//    NSInteger order;
//    if (self.inbound) {
//        order = indexPath.row;
//    } else {
//        order = [self.stationArray count]-indexPath.row-1;
//    }
//    self.transferCheckedStation = [self.stationArray objectAtIndex:order];
//    NSLog(@"transferCheckedStation: %@", self.transferCheckedStation.name);
//    
//    // Go to LinesListTableViewController
//    LinesListTableViewController *lltvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Lines_List"];
//    lltvc.transferCheckedStation = self.transferCheckedStation;
//    [self.navigationController pushViewController:lltvc animated:YES];
//}


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
