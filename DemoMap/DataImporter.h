/*
 File: DataImporter.h
 Abstract: Downloads, parses, and imports the iTunes top songs RSS feed into Core Data.
 Version: 1.4
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Line.h"

@class DataImporter, Line;

// Protocol for the importer to communicate with its delegate.
@protocol DataImporterDelegate <NSObject>

@optional

@end


@interface DataImporter : NSOperation {
@private
    id <DataImporterDelegate> __unsafe_unretained delegate;
}

@property NSManagedObjectContext *insertionContext;

- (void)main;


@end

