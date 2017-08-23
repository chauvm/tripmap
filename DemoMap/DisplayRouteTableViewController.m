//
//  DisplayRouteTableViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/17/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "DisplayRouteTableViewController.h"
#import "StationDetailsViewController.h"
#import "Direction.h"
#import "AppDelegate.h"

@interface DisplayRouteTableViewController ()

@end

@implementation DisplayRouteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = [NSString stringWithFormat:@"Route from %@ to %@", self.startStation.name, self.endStation.name];
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self loadRoute];
    [self findRoute];
//    self.tableView.tableHeaderView set
    self.instructionLabel.text = self.instruction;
}

- (void)loadRoute {
    self.stationArray = [[NSArray alloc] initWithObjects:self.startStation, self.endStation, nil];
}

- (void)findRoute {
    // check if two stations belong to the same direction. return A-B
    Direction *directionA = [self.startStation valueForKeyPath:@"directionStations.self"];
    Direction *directionB = [self.endStation valueForKeyPath:@"directionStations.self"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    self.stationArray = [directionA.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSLog(@"Direction A: %@, direction B: %@", directionA.name, directionB.name);
    NSLog(@"Direction A's line: %@, direction B's line: %@", directionA.line, directionB.line);
    if ([directionA.line isEqualToString:directionB.line]) {
        self.stationArray = [self findRouteSameLineFrom:self.startStation To:self.endStation startDirection:directionA endDirection:directionB];
    } else {
        NSLog(@"Different Lines");
        // if two different lines, is there a transfer station in A's direction, same for B
        // if one of them doesn't have any transfer station on the same line, return nil >>>
            // actually must find all station name A, B, not just in their directions
        // two sets of transfer stations, and min distance from A and B to each transfer station
        // check if there exists station C that belongs to both A's line and B's line. Find A-C,C-B
        Station *transferFromA = [directionA getTransferStationToLine:directionB.line];
        if (transferFromA != nil) {
            NSLog(@"Found a transfer: %@", transferFromA);
            self.transferStationName = transferFromA.name;
            NSArray *stationsFromAtoTransfer = [self findRouteSameLineFrom:self.startStation To:transferFromA startDirection:directionA endDirection:directionA];
            NSLog(@"stations from A to transfer %@", [stationsFromAtoTransfer valueForKey:@"name"]);
            NSArray *stationsFromTransferToB = [self findRouteSameLineFrom:transferFromA To:self.endStation startDirection:directionA endDirection:directionB];
            NSLog(@"stations from transfer to B %@", [stationsFromTransferToB valueForKey:@"name"]);
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            [temp addObjectsFromArray:stationsFromAtoTransfer];
            [temp removeObjectAtIndex:[temp count] - 1];
            [temp addObjectsFromArray:stationsFromTransferToB];
            self.stationArray = temp;
            self.instruction = [NSString stringWithFormat:@"Need a transfer at %@", transferFromA.name];
        } else {
            NSLog(@"No transfer from A");
            self.instruction = [NSString stringWithFormat:@"We are unable to retrieve direction - No transfer stations found from %@", directionA.name];
        }
    }
}

- (NSArray *)findRouteSameLineFrom:(Station*)startStation
                                To:(Station*)endStation
                    startDirection:(Direction*)directionA
                      endDirection:(Direction*)directionB {
    NSArray *stationArray = [[NSArray alloc] init];
    // TODO: same line. there exist some common station between 2 directions - find min A-C,C-B
    NSLog(@"Same line");
    if ([startStation.name isEqualToString:endStation.name]) {
        // same station, return as loadRoute
        NSLog(@"Same station");
        self.instruction = @"Start and destination belongs to the same main station";
        stationArray = [[NSArray alloc] initWithObjects:startStation, nil];
    } else if (directionA == directionB) {
        NSLog(@"Same direction");
        self.instruction = [NSString stringWithFormat:@"Travel along %@", directionA.name ];
        stationArray = [self getRouteSameDirection:directionA startStation:startStation endStation:endStation];
    } else if ([self directionContains:directionA name:endStation.name]) {
        NSLog(@"direction A contains station B");
        self.instruction = [NSString stringWithFormat:@"Travel along %@", directionA.name ];
        stationArray = [self getSubRouteFromDirection:directionA startFrom:startStation.name endAt:endStation.name];
    } else {
        NSLog(@"Check common stations");
        Station *common = [self getCommonStationBetween:directionA andDirection:directionB start:startStation end:endStation];
        NSLog(@"Common: %@", common.name);
        if (common != nil) {
            self.instruction = [NSString stringWithFormat:@"Get to common station %@", common.name ];
            self.transferStationName = common.name;
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            [temp addObjectsFromArray:[self getRouteSameDirection:directionA startStation:startStation endStation:common]];
            [temp addObjectsFromArray:[self getSubRouteFromDirection:directionB startFrom:common.name  endAt:endStation.name]];
            stationArray = temp;
        } else {
            // to simplify, assume the reverse direction always exists
            if ([self directionContains:directionB name:startStation.name]) {
                NSLog(@"Direction B contains station A");
                self.instruction = [NSString stringWithFormat:@"%@ has starting point", directionB.name ];
                stationArray = [[[self getSubRouteFromDirection:directionB startFrom:endStation.name endAt:startStation.name] reverseObjectEnumerator] allObjects];
                
            } else {
                // find common along all lines
                Station *allCommon = [self getCommonStationBetween:directionA andDirection:directionB start:directionA.getStartStation end:directionB.getEndStation];
                NSLog(@"allCommon: %@", allCommon);
                if (allCommon != nil) {
                    self.instruction = [NSString stringWithFormat:@"Transfer to %@", allCommon.name];
                    self.transferStationName = allCommon.name;
                    NSMutableArray *temp = [[NSMutableArray alloc] init];
                    [temp addObjectsFromArray:[self getRouteSameDirection:directionA startStation:startStation endStation:allCommon]];
                    [temp removeObjectAtIndex:[temp count] - 1];
                    [temp addObjectsFromArray:[self getSubRouteFromDirection:directionB startFrom:allCommon.name  endAt:self.endStation.name]];
                    stationArray = temp;
                }
            }
        }
    }
    return stationArray;
}

- (Station*)getCommonStationBetween:(Direction*)directionA
                     andDirection:(Direction*)directionB
                            start:(Station*)start
                              end:(Station*)end {
    __block Station *common;

    // get along A's direction
    NSArray *stationsFromA = [self getStationsToEnd:directionA currentStation:start];
    NSArray *stationsToB = [self getStationsFromStart:directionB currentStation:end];
    NSArray *stationsNamesToB = [stationsToB valueForKey:@"name"];
    NSLog(@"stationsNamesToB: %@", stationsNamesToB);
    [stationsFromA enumerateObjectsUsingBlock:^(Station* stA, NSUInteger idxA, BOOL *stopA){
        if ([stationsNamesToB containsObject:stA.name]) {
            common = stA;
            *stopA = YES;
        }
    }];

    return common;
}


- (NSArray*)getStationsFromStart:(Direction*)direction
                  currentStation:(Station*)station {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *stations = [direction.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
    stations = [stations objectsAtIndexes:[stations indexesOfObjectsPassingTest:^BOOL(Station *obj, NSUInteger idx, BOOL *stop) {
        return ([obj.order compare:station.order] == NSOrderedAscending ||
                 [obj.order compare:station.order] == NSOrderedSame );
        
    }]];
    return stations;
}

- (NSArray*)getStationsToEnd:(Direction*)direction
                  currentStation:(Station*)station {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *stations = [direction.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
    stations = [stations objectsAtIndexes:[stations indexesOfObjectsPassingTest:^BOOL(Station *obj, NSUInteger idx, BOOL *stop) {
        return ([station.order compare:obj.order] == NSOrderedAscending ||
                [station.order compare:obj.order] == NSOrderedSame) ;
        
    }]];
    return stations;
}

// return stations from startStation to endStation, find the reverse direction if startStation.order > endStation.order
- (NSArray *)getRouteSameDirection:(Direction*)directionA
                             startStation:(Station*)startStation
                        endStation:(Station*)endStation {
    NSArray *resultArray = [[NSArray alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *stations = [directionA.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
    // remove stations out of range from A-B
    NSLog(@"Start order: %@, end order: %@", startStation.order, endStation.order);
    if ([startStation.order compare:endStation.order] == NSOrderedAscending ||
        [startStation.order compare:endStation.order] == NSOrderedSame
        ) {
        NSLog(@"right order");
//        self.instruction = [NSString stringWithFormat:@"The destination is on the same direction %@", directionA.name];
        // Return a new array containing elements greater than or equal to start's order, less than or equal to end's order
        resultArray = [self getSubRoute:stations startFrom:startStation.order endAt:endStation.order];
    } else {
        NSLog(@"wrong order - find the reverse direction first");
        // find if reverse direction exists
        NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Direction" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"start == %@ AND end == %@", directionA.end, directionA.start];
        [request setPredicate:predicate];
        [request setEntity:entity];
        [request setReturnsDistinctResults:YES];
        // Execute the fetch.
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (results == nil) {
            // if not, just list stations in reverse order
//            self.instruction = @"The destination is in the opposite direction";
            resultArray = [[[self getSubRoute:stations startFrom:endStation.order endAt:startStation.order] reverseObjectEnumerator] allObjects];
        } else {
            NSLog(@"Found a reverse direction: %@", results);
            Direction *reverseDirection = [self getDirectionWithNames:resultArray startFrom:startStation.name endAt:endStation.name];
            if (reverseDirection != nil) {
//                self.instruction = [NSString stringWithFormat:@"The destination is on the reverse direction %@ TO %@", directionA.end, directionA.start];
                NSLog(@"Direction: %@", reverseDirection);
                resultArray = [reverseDirection.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
                resultArray = [self getSubRouteFromNames:stations startFrom:startStation.name endAt:endStation.name];
            } else {
//                self.instruction = @"The destination is in the opposite direction";
                resultArray = [[[self getSubRoute:stations startFrom:endStation.order endAt:startStation.order] reverseObjectEnumerator] allObjects];
            }
        }
    }
    NSLog(@"Result Array: %@", [resultArray valueForKey:@"name"]);
    return resultArray;
}

// start must be before end
- (NSArray *)getSubRoute:(NSArray*)stations
                   startFrom:(NSNumber*)start
                     endAt:(NSNumber*)end {
    stations = [stations objectsAtIndexes:[stations indexesOfObjectsPassingTest:^BOOL(Station *obj, NSUInteger idx, BOOL *stop) {
        
        if ([start compare:end] == NSOrderedAscending || [start compare:end] == NSOrderedSame) {
            return (([obj.order compare:end] == NSOrderedAscending ||
                     [obj.order compare:end] == NSOrderedSame )     &&
                    ([start compare:obj.order] == NSOrderedAscending ||
                     [start compare:obj.order] == NSOrderedSame)      );
        } else {
            return (([obj.order compare:start] == NSOrderedAscending ||
                     [obj.order compare:start] == NSOrderedSame )     &&
                    ([end compare:obj.order] == NSOrderedAscending ||
                     [end compare:obj.order] == NSOrderedSame)      );
        }
        
    }]];
    NSLog(@"getSubRoute: %@", [stations valueForKey:@"name"]);
    if ([start compare:end] == NSOrderedAscending || [start compare:end] == NSOrderedSame) {
        return stations;
    } else {
        return [[stations reverseObjectEnumerator] allObjects];
    }
}

- (BOOL)directionContains:(Direction*)direction
                     name:(NSString*)name {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *stations = [direction.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSArray *stationsNames = [stations valueForKey:@"name"];
//    __block BOOL found;
//    [stations enumerateObjectsUsingBlock:^(Station *st, NSUInteger idxDir, BOOL *stopDir) {
//        if ([st.name isEqualToString:name]) {
//            found = YES;
//            *stopDir = YES;
//        }
//    }];
    return [stationsNames containsObject:name];
}

- (Direction*)getDirectionWithNames:(NSArray*)directions
                        startFrom:(NSString*)start
                            endAt:(NSString*)end {
    __block Direction *result;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [directions enumerateObjectsUsingBlock:^(Direction *dir, NSUInteger idxDir, BOOL *stopDir) {
        __block BOOL foundStart;
        __block BOOL foundEnd;
        NSArray *stations = [dir.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
        [stations enumerateObjectsUsingBlock:^(Station *obj, NSUInteger idxSt, BOOL *stopSt) {
            if ([obj.name isEqualToString:start]) {
                foundStart = YES;
            }
            if ([obj.name isEqualToString:end]) {
                foundEnd = YES;
            }
            if (foundStart && foundEnd) {
                result = dir;
                *stopSt = YES;
            }
        }];
        
        if (result != nil) {
            *stopDir = YES;
        }

    }];

    return result;
}

- (NSArray *)getSubRouteFromDirection:(Direction*)direction
                        startFrom:(NSString*)start
                            endAt:(NSString*)end {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *stations = [direction.stations sortedArrayUsingDescriptors:@[sortDescriptor]];
    return [self getSubRouteFromNames:stations startFrom:start endAt:end];
}

- (NSArray *)getSubRouteFromNames:(NSArray*)stations
               startFrom:(NSString*)start
                   endAt:(NSString*)end {
    __block NSNumber *startOrder;
    __block NSNumber *endOrder;
    NSLog(@"Station names: %@, %@", start, end);
    NSLog(@"getSubRouteFromNames stations: %@", [stations valueForKey:@"name"]);
    [stations enumerateObjectsUsingBlock:^(Station *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqualToString:start]) {
            startOrder = obj.order;
            NSLog(@"Found startOrder: %@", startOrder);
        }
        if ([obj.name isEqualToString:end]) {
            endOrder = obj.order;
            NSLog(@"Found endOrder: %@", endOrder);
        }
    }];
    if (startOrder != nil && endOrder != nil) {
        NSLog(@"Finding route");
        stations = [self getSubRoute:stations startFrom:startOrder endAt:endOrder];
//        NSLog(@"Stations from reverse: %@", stations);
    } else {
        NSLog(@"cannot find station names in list");
    }
    return stations;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Route_Cell" forIndexPath:indexPath];
    Station *station = [self.stationArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"Start from: %@", station.name];
        cell.backgroundColor = [AppDelegate lightGrayColor];
    } else if (indexPath.row == [self.stationArray count] - 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"Final destination: %@", station.name];
        cell.backgroundColor = [AppDelegate lightGrayColor];
    } else if([station.name isEqualToString:self.transferStationName]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Transfer station: %@", station.name];
        cell.backgroundColor = [AppDelegate lightYellowColor];
    } else {
        cell.textLabel.text = station.name;
    }
    
    if (station.accessible) {
        if (station.transfer) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Accessible and can transfer to %@,", station.transfer_lines];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Accessible, not a transfer"];
        }
    } else {
        if (station.transfer) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Can transfer to %@. No accessibility information", station.transfer_lines];
        } else {
            cell.detailTextLabel.text = @"Not a transfer. No accessibility information";
        }
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Station *selectedStation = [self.stationArray objectAtIndex:indexPath.row];
    StationDetailsViewController *sdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Station_Detail"];
    sdvc.station = selectedStation; // hand off the current product to the detail view controller
    sdvc.currentDirection = [selectedStation valueForKeyPath:@"directionStations.self"];
    
    [self.navigationController pushViewController:sdvc animated:YES];
    
    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
