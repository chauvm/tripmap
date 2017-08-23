//
//  FavoriteTipsViewController.h
//  DemoMap
//
//  Created by Anh Huynh on 6/9/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@interface FavoriteTipsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *tagPicker;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) Station *station;
@property (strong, nonatomic) NSString *directionName;
@property (strong, nonatomic) NSString *end;




@end
