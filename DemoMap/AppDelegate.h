//
//  AppDelegate.h
//  DemoMap
//
//  Created by Anh Huynh on 5/10/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (UIColor*)lightYellowColor;
+ (UIColor*)lightGrayColor;

@end

