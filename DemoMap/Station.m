//
//  Station.m
//  DemoMap
//
//  Created by Anh Huynh on 5/23/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "Station.h"


@implementation Station

@dynamic name;
@dynamic transfer;
@dynamic order;
@dynamic directionStations;
@dynamic accessible;
@dynamic transfer_lines;
@dynamic stop_long_name;
@dynamic stop_lat;
@dynamic stop_lon;
@dynamic parent_station;
@dynamic stop_id;
- (NSComparisonResult) compare:(Station *)otherObject {
    if (self.order > otherObject.order) {
        return (NSComparisonResult)NSOrderedDescending;
    } else if (self.order < otherObject.order) {
        return (NSComparisonResult)NSOrderedAscending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    };
}
@end
