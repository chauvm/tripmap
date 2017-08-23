//
//  SearchMainTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/16/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "SearchMainTableViewController.h"
#import "SearchResultsTableController.h"
#import "StationDetailsViewController.h"
#import "ChooseStationsViewController.h"
#import "AppDelegate.h"

@interface SearchMainTableViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) SearchResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property Station *sendbackSelectedStation;

@end

@implementation SearchMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _resultsTableController = [[SearchResultsTableController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    self.resultsTableController.wantSelectStation = self.wantSelectStation;
    
    if (self.wantSelectStation) {
        self.navigationItem.title = @"Select a station";
    } else {
        self.navigationItem.title = @"View a station's details";
    }
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    [self loadStationArray];
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    
//    NSLog(@"Search start is: %hhd", self.searchStart);
//    NSLog(@"Search end is: %hhd", self.searchEnd);
}

- (void)loadStationArray {
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Line"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCity = [userDefaults objectForKey:@"CurrentCity"];
    if (currentCity == nil) {
        currentCity = @"Boston, Massachusetts, USA";
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"state == %@", currentCity];
    NSSortDescriptor *alphabet_route_id = [[NSSortDescriptor alloc] initWithKey:@"route_id" ascending:YES];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:alphabet_route_id]];
    NSError *requestError = nil;
    self.lines = [[NSArray alloc] init];
    self.directionArray = [[NSArray alloc] init];
    self.stationArray = [[NSMutableArray alloc] init];
    self.stationNameArray = [[NSMutableArray alloc] init];
    self.resultsArray = [[NSArray alloc] init];
    self.stations = [[NSArray alloc] init];
    
    self.lines = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *sortDescriptorDirectionName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    if ([self.lines count] > 0) {
        NSLog(@"Get some lines in Lines List: %lu", (unsigned long)[self.lines count]);
        
        for (Line *lineItem in self.lines) {
            self.directionArray = [lineItem.directions sortedArrayUsingDescriptors:@[sortDescriptorDirectionName]];
            
            for (Direction *direction in self.directionArray) {
                [self.stationArray addObjectsFromArray:[direction.stations sortedArrayUsingDescriptors:@[sortDescriptor]]];
            }
        }
        [self.stationArray enumerateObjectsUsingBlock: ^(Station *obj, NSUInteger idx, BOOL *stop) {
            [self.stationNameArray addObject:obj.name];
        }];
        self.resultsArray = self.stationNameArray;
        self.stations = self.stationArray;
    } else {
        NSLog(@"No line found in Lines List");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Station *station = self.stations[indexPath.row];
    [self configureCell:cell forStation:station];

    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [AppDelegate lightGrayColor];
    }
    else
    {
        cell.backgroundColor = [AppDelegate lightYellowColor];
    }
    return cell;
}

- (void)selectStationButtonClicked :(UIButton *)sender {
    NSLog(@"Station selected from MAIN TABLE");
    Station *selectedStation = ([sender.accessibilityLabel isEqualToString:@"Select"]) ?
    self.stations[sender.tag] : self.resultsTableController.filteredStations[sender.tag];
    NSLog(@"SelectedStation: %@", selectedStation);
    self.sendbackSelectedStation = selectedStation;
    [self performSegueWithIdentifier:@"unwindAndSelectStationIdentifier" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"unwindAndSelectStationIdentifier"]) {
        NSLog(@"Reach main prepareForSegue");
        ChooseStationsViewController *csvvc = [segue destinationViewController];
        if (self.searchStart) {
            NSLog(@"unwind with start station");
            csvvc.startStation = self.sendbackSelectedStation;
            csvvc.isSelectingStart = YES;
        } else if (self.searchEnd) {
            NSLog(@"unwind with end station");
            csvvc.endStation = self.sendbackSelectedStation;
            csvvc.isSelectingStart = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Station *selectedStation = (tableView == self.tableView) ?
    self.stations[indexPath.row] : self.resultsTableController.filteredStations[indexPath.row];
    StationDetailsViewController *sdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Station_Detail"];
    sdvc.station = selectedStation; // hand off the current product to the detail view controller
    sdvc.currentDirection = [selectedStation valueForKeyPath:@"directionStations.self"];
    
    [self.navigationController pushViewController:sdvc animated:YES];
    
    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


// here we are the table view delegate for both our main table and filtered table, so we can
// push from the current navigation controller (resultsTableController's parent view controller
// is not this UINavigationController)
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.wantSelectStation) {
        NSLog(@"didSelectRow");
        NSLog(@"Station selected from MAIN TABLE");
        Station *selectedStation = (tableView == self.tableView) ?
        self.stations[indexPath.row] : self.resultsTableController.filteredStations[indexPath.row];
        NSLog(@"SelectedStation: %@", selectedStation);
        self.sendbackSelectedStation = selectedStation;
        [self performSegueWithIdentifier:@"unwindAndSelectStationIdentifier" sender:self];
    } else {
        Station *selectedStation = (tableView == self.tableView) ?
        self.stations[indexPath.row] : self.resultsTableController.filteredStations[indexPath.row];
        StationDetailsViewController *sdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Station_Detail"];
        sdvc.station = selectedStation; // hand off the current product to the detail view controller
        sdvc.currentDirection = [selectedStation valueForKeyPath:@"directionStations.self"];
    
        [self.navigationController pushViewController:sdvc animated:YES];
    
        // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.stations mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // yearIntroduced field matching
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
//        NSNumber *targetNumber = [numberFormatter numberFromString:searchString];
//        if (targetNumber != nil) {   // searchString may not convert to a number
//            lhs = [NSExpression expressionForKeyPath:@"yearIntroduced"];
//            rhs = [NSExpression expressionForConstantValue:targetNumber];
//            finalPredicate = [NSComparisonPredicate
//                              predicateWithLeftExpression:lhs
//                              rightExpression:rhs
//                              modifier:NSDirectPredicateModifier
//                              type:NSEqualToPredicateOperatorType
//                              options:NSCaseInsensitivePredicateOption];
//            [searchItemsPredicate addObject:finalPredicate];
//            
//            // price field matching
//            lhs = [NSExpression expressionForKeyPath:@"introPrice"];
//            rhs = [NSExpression expressionForConstantValue:targetNumber];
//            finalPredicate = [NSComparisonPredicate
//                              predicateWithLeftExpression:lhs
//                              rightExpression:rhs
//                              modifier:NSDirectPredicateModifier
//                              type:NSEqualToPredicateOperatorType
//                              options:NSCaseInsensitivePredicateOption];
//            [searchItemsPredicate addObject:finalPredicate];
//        }
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    // hand over the filtered results to our search results table
    SearchResultsTableController *tableController = (SearchResultsTableController *)self.searchController.searchResultsController;
    tableController.filteredStations = searchResults;
    [tableController.tableView reloadData];
}


#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}



//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

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





@end
