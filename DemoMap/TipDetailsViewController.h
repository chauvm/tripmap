//
//  TipDetailsViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/15/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TipDetailsViewController : UIViewController
@property (strong, nonatomic) PFObject *currentTip;
@property (strong, nonatomic) NSString *stationChildName;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *creationLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
