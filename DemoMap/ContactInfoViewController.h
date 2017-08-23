//
//  ContactInfoViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/21/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactInfoViewController : UIViewController <UIAlertViewDelegate>
- (IBAction)callAgency:(id)sender;
@property (strong, nonatomic) NSString *currentPhoneNumber;

@end
