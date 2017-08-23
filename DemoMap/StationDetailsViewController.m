//
//  StationDetailsViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 5/10/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "StationDetailsViewController.h"
#import "FavoriteTipsViewController.h"
#import "TipFormViewController.h"
#import "AppDelegate.h"


@interface StationDetailsViewController ()
- (IBAction)favoriteTips:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)getUber:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *alertTextView;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *scheduleDetails;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property NSString *currentCity;
#define GET_UBER 1
#define GET_SEEINGEYE 2

@end
static NSString *MBTA_API_KEY = @"YCEboTCED0KDfTx5GBBypw";
static NSString *MBTA_URL = @"http://realtime.mbta.com/developer/api/v2/";
@implementation StationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.station.name;
    
    self.viewTips1Button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.viewTips1Button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.viewTips1Button setTitle:[NSString stringWithFormat:@"Tips for %@ direction", self.currentDirection.end] forState: UIControlStateNormal];
    
    self.viewTips2Button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.viewTips2Button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.viewTips2Button setTitle:[NSString stringWithFormat:@"Tips for %@ direction", self.currentDirection.start] forState: UIControlStateNormal];
    
    self.viewTipsParentButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.viewTipsParentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.viewTipsParentButton setTitle:[NSString stringWithFormat:@"Tips for %@ main station", self.station.name] forState: UIControlStateNormal];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.currentCity = [userDefaults objectForKey:@"CurrentCity"];
    
    NSString *transfer_info;
    if (self.station.transfer) {
        transfer_info = [NSString stringWithFormat:@"This station can connect to lines %@", self.station.transfer_lines];
    } else {
        transfer_info = @"This station is not a transfer point";
    }
    self.accessibleImageView.isAccessibilityElement = YES;
    if (self.station.accessible) {
        //accessibility_info = @"This station is wheelchair accessible";
        self.accessibleImageView.image = [UIImage imageNamed:@"Accessible"];
        self.accessibleImageView.accessibilityLabel = @"This station is wheelchair accessible";
    } else {
        //accessibility_info = @"No accessibility information available";
        self.accessibleImageView.image = [UIImage imageNamed:@"NotAccessible"];
        self.accessibleImageView.accessibilityLabel = @"No accessibility information available";
    }
    [self.addressTextView setText:transfer_info];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Get server time
//    [self checkTime:self];
    
    // Get alerts
    [self getAlerts:self];
    
    // Get predictions
    [self getSchedule:self];
}

- (void)checkTime:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    // Show current servertime
    NSString *function = @"servertime";
    NSString *urlAsString = [NSString stringWithFormat:@"%@%@?api_key=%@&format=json", MBTA_URL, function, MBTA_API_KEY];
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:urlRequest queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if (error == nil && data.length >0) {
             NSData *jsonObject = [NSJSONSerialization
                                   JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *json_dict = jsonObject;
                 NSInteger servertime = [json_dict.allValues[0] integerValue];
                 NSString *epochtime = [NSString stringWithFormat:@"%ld", (long)servertime];
                 NSTimeInterval seconds = [epochtime doubleValue];
                 NSDate *epochDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.timeLabel setText:[formatter stringFromDate:epochDate]];
                 });
             }
         } else {
             NSLog(@"Unable to get server time: %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.timeLabel setText:@"Unable to get server time"];
             });
         }
     }];
    
    [self performSelector:@selector(checkTime:) withObject:self afterDelay:5.0];
}

// Porter Square: http://realtime.mbta.com/developer/api/v2/alertsbystop?api_key=wX9NwuHnZU2ToO7GmGR9uw&stop=Porter%20Square&include_access_alerts=true&include_service_alerts=true&format=json
// Alewife: http://realtime.mbta.com/developer/api/v2/alertsbystop?api_key=wX9NwuHnZU2ToO7GmGR9uw&stop=70061&include_access_alerts=true&include_service_alerts=true&format=json
- (void)getAlerts:(id)sender {
    if ([self.currentCity isEqualToString:@"Boston, Massachusetts, USA"]) {
        NSString *function = @"alertsbystop";
    //    NSString *stop_id = @"70061"; // hard code for Alewife
        NSString *stop_id = self.station.stop_id; // hard code for Porter Square commuter rail
        NSString *urlAsString = [NSString stringWithFormat:@"%@%@?api_key=%@&stop=%@&include_access_alerts=true&include_service_alerts=true&format=json", MBTA_URL, function, MBTA_API_KEY, stop_id];
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60.0f];
        [urlRequest setHTTPMethod:@"GET"];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection
         sendAsynchronousRequest:urlRequest queue:queue
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error) {
             __block NSString *responseText = @"";
             if (error == nil && data.length >0) {
                 NSData *jsonObject = [NSJSONSerialization
                                       JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                 if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                     NSDictionary *json_dict = jsonObject;
                     NSArray *alertsArray = [json_dict objectForKey:@"alerts"];
    //                 NSLog(@"alertsArray: %@", alertsArray);
                     [alertsArray enumerateObjectsUsingBlock:^(id alertObj, NSUInteger alertIdx, BOOL *alertStop) {
                         responseText = [NSString stringWithFormat:@"%@. %@", [alertObj objectForKey:@"header_text"], responseText];
                     }];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (responseText) {
                             // update alert text view
                             [self.alertTextView setText:[NSString stringWithFormat:@"Alerts: %@", responseText]];
                         } else {
                             [self.alertTextView setText:@"There is currently no alerts"];
                         }
                     });
                 }
             } else {
                 NSLog(@"Unable to get alerts: %@", error);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // update alert text view
                     [self.alertTextView setText:@"Unable to get alerts for this station"];
                 });
             }
         }];
    } else {
        [self.alertTextView setText:[NSString stringWithFormat:@"Getting station alerts is not yet available for %@, but available for Boston, MA", self.currentCity]];
    }

}

// to get Alewife's schedule: http://realtime.mbta.com/developer/api/v2/schedulebystop?api_key=YCEboTCED0KDfTx5GBBypw&stop=70061&format=json
- (void)getSchedule:(id)sender {
    if ([self.currentCity isEqualToString:@"Boston, Massachusetts, USA"]) {
        NSString *function = @"schedulebystop";
    //    NSString *stop_id = @"70061"; // hard code for Alewife
        NSString *stop_id = self.station.stop_id;
        NSString *urlAsString = [NSString stringWithFormat:@"%@%@?api_key=%@&stop=%@&format=json", MBTA_URL, function, MBTA_API_KEY, stop_id];
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setTimeoutInterval:60.0f];
        [urlRequest setHTTPMethod:@"GET"];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection
         sendAsynchronousRequest:urlRequest queue:queue
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error) {
             __block NSString *responseText = @"";
             if (error == nil && data.length >0) {
                 NSData *jsonObject = [NSJSONSerialization
                                       JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                 if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                     NSDictionary *json_dict = jsonObject;
                     NSArray *modes = [json_dict objectForKey:@"mode"];
                     if ([modes count] > 0) {
                         NSArray *routes = [modes[0] objectForKey:@"route"];
                         NSArray *directions = [routes[0] objectForKey:@"direction"];
                         [directions enumerateObjectsUsingBlock:^(id directionObj, NSUInteger directionIdx, BOOL *directionStop) {
                             // TODO: display info here
                             NSDictionary *firstTrip = [directionObj objectForKey:@"trip"][0];
                             NSString *info = [NSString stringWithFormat:@"%@, %@ will arrive in %@",
                                               [directionObj objectForKey:@"direction_name"],
                                               [firstTrip objectForKey:@"trip_name"],
                                               [self getRemainingTime:[[firstTrip objectForKey:@"sch_arr_dt"] integerValue]]];
                             
                             responseText = [NSString stringWithFormat:@"%@. %@", info, responseText];
                             
                         }];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (responseText) {
                                 [self.scheduleDetails setText:responseText];
                             } else {
                                 [self.scheduleDetails setText:@"No schedule information available"];
                             }
                         });
                     } else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.scheduleDetails setText:@"No trains available this time"];
                         });
                     }
                 }

             } else {
                 NSLog(@"Unable to get schedules: %@", error);
             }
         }];
    } else {
        [self.scheduleDetails setText:[NSString stringWithFormat:@"Getting real time schedule is not yet available for %@, but available for Boston, MA", self.currentCity]];
    }
}

- (NSString *)getRemainingTime:(NSInteger)time {
    NSDate *epochtime = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    if ([epochtime compare:[NSDate date]] == NSOrderedDescending) {
        NSTimeInterval diff = [epochtime timeIntervalSinceNow];
        long seconds = lroundf(diff); // Modulo (%) operator below needs int or long
        
        int hour = seconds / 3600;
        int mins = (seconds % 3600) / 60;
        NSString *stringHour = @"";
        if (hour > 0) {
            if (hour > 1) {
                stringHour = [NSString stringWithFormat:@"%d hours", hour ];
            } else {
                stringHour = [NSString stringWithFormat:@"%d hour", hour ];
            }
        }
        NSString *stringMinute = @"";
        if (mins > 1) {
            stringMinute = [NSString stringWithFormat:@"%d minutes", mins ];
        } else {
            stringMinute = [NSString stringWithFormat:@"%d minute", mins ];
        }
        
        return [NSString stringWithFormat:@"%@ %@", stringHour, stringMinute];
    } else {
        return @"0 minute";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getDirectionNameOnly:(NSString*)directionName {
    if ([directionName rangeOfString:@"weekend"].location == NSNotFound) {
        if ([directionName rangeOfString:@"weekdays"].location == NSNotFound) {
            return directionName;
        } else {
            return [self removeScheduleType:@"weekdays" from:directionName];
        }
    } else {
        return [self removeScheduleType:@"weekend" from:directionName];
    }
}

- (NSString *)removeScheduleType:(NSString*)type
                            from:(NSString*)directionName {
    NSArray *components = [directionName componentsSeparatedByString:@" - "];
    NSMutableArray *componentsWithoutType = [NSMutableArray arrayWithArray:components];
    [componentsWithoutType removeObjectAtIndex:[components count] - 1];
    NSString *joinedString = [componentsWithoutType componentsJoinedByString:@""];
    if ([joinedString rangeOfString:type].location == NSNotFound) {
        NSLog(@"remove schedule type successfully: %@", joinedString);
    } else {
        NSLog(@"schedule type remained: %@", joinedString);
    }
    return joinedString;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ShowTipForm"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        TipFormViewController* tfvc = (TipFormViewController*)[navController topViewController];
        tfvc.currentDirectionName = [self getDirectionNameOnly: self.currentDirection.name];
        tfvc.station = self.station;
    }
}


// source: https://developer.uber.com/v1/deep-linking/
- (IBAction)getUber:(id)sender {
    NSLog(@"Get Uber");
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // uber://?action=setPickup&pickup=my_location
        // uber://?client_id=YOUR_CLIENT_ID&action=setPickup&pickup[latitude]=37.775818&pickup[longitude]=-122.418028&pickup[nickname]=UberHQ&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103&dropoff[latitude]=37.802374&dropoff[longitude]=-122.405818&dropoff[nickname]=Coit%20Tower&dropoff[formatted_address]=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d

        NSLog(@"Uber installed");
        NSURL *myURL = [NSURL URLWithString:@"uber://?action=setPickup&pickup=my_location"];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    else {
        // No Uber app! Open Mobile Website.
        NSLog(@"Uber NOT installed");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User app has not been installed"
                                                        message:@"Do you want to install Uber?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Install"];
        alert.tag = GET_UBER;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index = %ld, tag = %ld", (long)buttonIndex, (long)alertView.tag);
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked Cancel");
    }
    else if(alertView.tag == GET_UBER)
    {
        NSLog(@"You have clicked Install Uber");
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://geo.itunes.apple.com/us/app/uber/id368677368?mt=8&uo=6"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8&uo=6"]];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=294409923&mt=8"]];
    } else if (alertView.tag == GET_SEEINGEYE) {
        NSLog(@"You have clicked Install Blind Square");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/blindsquare/id500557255?mt=8&uo=4"]];
    }
}
- (IBAction)favoriteTips:(id)sender {
    FavoriteTipsViewController *ftvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Favorite_Tips"];
    ftvc.station = self.station;
    if ([sender tag] == 1) {
        ftvc.directionName = self.currentDirection.name;
        ftvc.end = self.currentDirection.end;
    } else if ([sender tag] == 2) {
        ftvc.directionName = [self getReverseDirection];
        ftvc.end = self.currentDirection.start;
    } else {
        // 3, parent tips
        ftvc.directionName = @"Parent";
//        ftvc.end = self.currentDirection.start;
    }
    [self.navigationController pushViewController:ftvc animated:YES];
}

- (NSString*)getReverseDirection{
    return [NSString stringWithFormat:@"%@ TO %@", self.currentDirection.end, self.currentDirection.start];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

- (IBAction)unwindAndSaveTip:(UIStoryboardSegue *)segue {
    
}

// This function opens Blind Square instead of seeing eye
- (IBAction)getSeeingEye:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"blindsquare://api/place"]]) {
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Blind Square app has not been installed"
                                                        message:@"Do you want to install Blind Square?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Install"];
        alert.tag = GET_SEEINGEYE;
        [alert show];
    }
}
@end
