/*
 File: DataImporter.m
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "DataImporter.h"
#import "Line.h"
#import "Direction.h"
#import "Station.h"
#import "AppDelegate.h"

// Class extension for private properties and methods.
@interface DataImporter ()

@end


@implementation DataImporter

- (void)main {
    
    self.insertionContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    // now I want to read data from json file
    BOOL readLineData = YES;
    
    
    NSArray *city_array = @[@"Boston", @"NYC_with_schedule", @"SanFran_2", @"Washington_2", @"Rio_2"];
    // Read Boston's Data
    if (readLineData) {
        for (id city in city_array) {
            NSError *errorReadJson = nil;
            NSDictionary *lines_data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:city ofType:@"json"]]
                                                                       options:kNilOptions
                                                                         error:&errorReadJson];
            if (errorReadJson != nil) {
                NSLog(@"Error: was not able to load json.");
            } else {
                NSLog(@"Able to read from json");
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
                for (id state in lines_data.allKeys) {
                    NSArray *lines = lines_data[state];
                    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Line *newLine = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"Line" inManagedObjectContext:self.insertionContext];
                        newLine.route_name = [obj objectForKey:@"route_name"];
                        newLine.route_long_name = [obj objectForKey:@"route_long_name"];
                        newLine.route_color = [obj objectForKey:@"route_color"];
                        newLine.route_id = [obj objectForKey:@"route_id"];
                        newLine.state = state;
                        NSLog(@"%@",newLine.route_name);
                        
                        NSArray *directionArray = [obj objectForKey:@"directions"];
                        [directionArray enumerateObjectsUsingBlock:^(id directionObj, NSUInteger directionIdx, BOOL *directionStop) {
                            Direction *direction = [NSEntityDescription
                                                    insertNewObjectForEntityForName:@"Direction"
                                                    inManagedObjectContext:self.insertionContext];
                            
                            direction.name = [directionObj objectForKey:@"name"];
                            direction.start = [directionObj objectForKey:@"start"];
                            direction.end = [directionObj objectForKey:@"end"];
                            direction.line = [directionObj objectForKey:@"line"];
                            direction.lineRel = newLine;
                            
                            
                            NSArray *stationArray = [directionObj objectForKey:@"stations"];
                            
                            [stationArray enumerateObjectsUsingBlock:^(id stationObj, NSUInteger stationIdx, BOOL *stationStop) {
                                Station *station = [NSEntityDescription
                                                    insertNewObjectForEntityForName:@"Station"
                                                    inManagedObjectContext:self.insertionContext];
                                station.name = [stationObj objectForKey:@"stop_name"];
                                station.stop_long_name = [stationObj objectForKey:@"stop_long_name"];
                                station.stop_id = [stationObj objectForKey:@"stop_id"];
                                station.parent_station = [stationObj objectForKey:@"parent_station"];
                                station.order = [formatter numberFromString:[stationObj objectForKey:@"order"]];
                                station.stop_lat = [stationObj objectForKey:@"stop_lat"];
                                station.stop_lon = [stationObj objectForKey:@"stop_lon"];
                                
                                station.transfer_lines = [stationObj objectForKey:@"transfer_lines"];
                                station.accessible = [[stationObj objectForKey:@"accessible"] boolValue];
                                station.transfer = [[stationObj objectForKey:@"transfer"] boolValue];
                                
                                station.directionStations = direction;
                                
                            }];
                        }];
                    }];
                    
                    
                }
                NSError *errorState;
                if (![self.insertionContext save:&errorState]) {
                    NSLog(@"Whoops, couldn't save city data: %@", [errorState localizedDescription]);
                } else {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setBool:YES forKey:@"CityData"];
                    [userDefaults synchronize];
                }
                
            }
        }
    }
    
}



- (BOOL)createNewLine:(NSString *)paramLineType
                state:(NSString *)paramState{
    BOOL result = NO;
    if ([paramLineType length] == 0 || [paramState length] == 0) {
        NSLog(@"LineType and State are mandatory");
        return result;
    }
    Line *newLine = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Line" inManagedObjectContext:self.insertionContext];
    if (newLine != nil) {
        newLine.route_name = paramLineType;
        newLine.state = paramState;
        
        NSError *savingError = nil;
        if ([self.insertionContext save:&savingError]) {
            NSLog(@"Successfully saved the context in DataImporter");
            return YES;
        } else {
            NSLog(@"Failed to save the context in DataImporter. Error = %@", savingError);
        }
    } else {
        NSLog(@"Failed to create a new line in DataImporter");
    }
    return result;
}



@end

