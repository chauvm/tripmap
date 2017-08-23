//
//  Line.h
//  DemoMap
//
//  Created by Anh Huynh on 5/23/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Line : NSManagedObject

@property (nonatomic, retain) NSString * route_name;
@property (nonatomic, retain) NSString * route_long_name;
@property (nonatomic, retain) NSString * route_color;

@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * route_id;

@property (nonatomic, retain) NSSet *directions;
@end
@interface Line (CoreDataGeneratedAccessors)

- (void)addDirectionsObject:(NSManagedObject *)value;
- (void)removeDirectionsObject:(NSManagedObject *)value;
- (void)addDirections:(NSSet *)values;
- (void)removeDirections:(NSSet *)values;
@end
