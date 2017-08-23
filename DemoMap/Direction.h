//
//  Direction.h
//  DemoMap
//
//  Created by Anh Huynh on 5/23/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Line, Station;

@interface Direction : NSManagedObject

@property (nonatomic, retain) NSString * line;
@property (nonatomic, retain) NSString * start;
@property (nonatomic, retain) NSString * end;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Line *lineRel;
@property (nonatomic, retain) NSSet *stations;
@end

@interface Direction (CoreDataGeneratedAccessors)

- (void)addStationsObject:(Station *)value;
- (void)removeStationsObject:(Station *)value;
- (void)addStations:(NSSet *)values;
- (void)removeStations:(NSSet *)values;
- (Station*)getStartStation;
- (Station*)getEndStation;
- (NSArray*)getTransferStations;
- (Station*)getTransferStationToLine:(NSString*)otherLine;

@end
