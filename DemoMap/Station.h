//
//  Station.h
//  DemoMap
//
//  Created by Anh Huynh on 5/23/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Station : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * stop_long_name;
@property (nonatomic, retain) NSString * stop_id;
@property (nonatomic, retain) NSString * parent_station;

@property (nonatomic, retain) NSString * stop_lon;
@property (nonatomic, retain) NSString * stop_lat;


@property (nonatomic, retain) NSString * transfer_lines;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic) BOOL accessible;
@property (nonatomic) BOOL transfer;
@property (nonatomic, retain) NSManagedObject *directionStations;

@end
