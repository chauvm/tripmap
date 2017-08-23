//
//  SubclassConfigViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/10/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface SubclassConfigViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
- (IBAction)logOutButtonTapAction:(id)sender;
- (IBAction)exploreButton:(id)sender;

@end
