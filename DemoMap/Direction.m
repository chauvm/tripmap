//
//  Direction.m
//  DemoMap
//
//  Created by Anh Huynh on 5/23/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "Direction.h"
#import "Line.h"
#import "Station.h"


@implementation Direction

@dynamic line;
@dynamic start;
@dynamic end;
@dynamic name;
@dynamic lineRel;
@dynamic stations;


- (Station *)getStartStation {
    NSArray *allStations = [self.stations allObjects];
    NSArray *stationNames = [allStations valueForKey:@"name"];
    NSInteger anIndex=[stationNames indexOfObject:self.start];
    return [allStations objectAtIndex:anIndex];
}

- (Station *)getEndStation {
    NSArray *allStations = [self.stations allObjects];
    NSArray *stationNames = [allStations valueForKey:@"name"];
    NSInteger anIndex=[stationNames indexOfObject:self.end];
    return [allStations objectAtIndex:anIndex];
}

- (NSArray*)getTransferStations {
    NSArray *allStations = [self.stations allObjects];
    NSArray *transferStations = [allStations objectsAtIndexes: [allStations indexesOfObjectsPassingTest:^BOOL(Station *obj, NSUInteger idx, BOOL *stop) {
        return (obj.transfer);
    }]];
    return transferStations;
};
- (Station*)getTransferStationToLine:(NSString*)otherLine {
    NSArray *transferStations = [self getTransferStations];
    NSArray *transferArray = [transferStations objectsAtIndexes: [transferStations indexesOfObjectsPassingTest:^BOOL(Station *obj, NSUInteger idx, BOOL *stop) {
        return [[self getTransferLinesArray:obj.transfer_lines] containsObject:otherLine];
    }]];
    if ([transferArray count] > 0) {
        return [transferArray objectAtIndex:0];
    }
    return nil;
};

- (NSArray*)getTransferLinesArray:(NSString*)transferLines {
    return [transferLines componentsSeparatedByString:@","];
}

@end
