//
//  TutorialChildViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/19/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialChildViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (assign, nonatomic) NSInteger index;
@property NSString *titleText;
@property NSString *content;

@property (weak, nonatomic) IBOutlet UILabel *contentText;


@end
