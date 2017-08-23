//
//  LocationViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 5/31/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *currentStationName;

@end
