//
//  StationDetailsViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 5/10/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"
#import "Direction.h"

@interface StationDetailsViewController : UIViewController<UIAlertViewDelegate>
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@property (weak, nonatomic) IBOutlet UIButton *viewTips2Button;
@property (weak, nonatomic) IBOutlet UIButton *viewTips1Button;
@property (weak, nonatomic) IBOutlet UIButton *viewTipsParentButton;

- (IBAction)unwindAndSaveTip:(UIStoryboardSegue *)segue;
@property NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Station *station;
@property (strong, nonatomic) Direction *currentDirection;
- (IBAction)getSeeingEye:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *accessibleImageView;

@end
