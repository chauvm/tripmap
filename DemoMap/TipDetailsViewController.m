//
//  TipDetailsViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/15/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "TipDetailsViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface TipDetailsViewController ()

@end

@implementation TipDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Tip Details";
    
    NSString *direction = [self.currentTip objectForKey:@"direction"];
    if ([direction isEqualToString:@"Parent"]) {
        [self.locationLabel setText:[NSString stringWithFormat:@"Location: %@ main station", self.stationChildName]];
    } else {
        [self.locationLabel setText:[NSString stringWithFormat:@"Location: %@ station in %@ direction", [self.currentTip objectForKey:@"stationName"], direction]];
    }

    [self.tagLabel setText:[self getTag]];
    [self.contentTextView setText:[self.currentTip objectForKey:@"content"]];
    [self.contentTextView setBackgroundColor:[AppDelegate lightYellowColor]];
    [self.creationLabel setText:[self getCreation]];
    [self getStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)getTag {
    if ([self.currentTip objectForKey:@"navigation"]) {
        return [NSString stringWithFormat:@"Tag: navigation"];
    } else if ([self.currentTip objectForKey:@"warning"]) {
        return [NSString stringWithFormat:@"Tag: warning"];
    } else if ([self.currentTip objectForKey:@"recommendation"]) {
        return [NSString stringWithFormat:@"Tag: recommendation"];
    } else {
        return [NSString stringWithFormat:@"Tag: uncategorized"];
    }
}

- (NSString*)getCreation {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormat stringFromDate:self.currentTip.createdAt];
    return [NSString stringWithFormat:@"By %@ on %@", [self.currentTip objectForKey:@"username"], date];
}

- (void)getStatus {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        PFQuery *query = [PFQuery queryWithClassName:@"tipStatusObject"];
        [query whereKey:@"tip_id" equalTo:self.currentTip.objectId];
        [query whereKey:@"favored" equalTo:[NSNumber numberWithBool:YES]];
        int favored = [query countObjects];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
            } else {
                // error
            }
        }];
        
        PFQuery *snubbedQuery = [PFQuery queryWithClassName:@"tipStatusObject"];
        [snubbedQuery whereKey:@"tip_id" equalTo:self.currentTip.objectId];
        [snubbedQuery whereKey:@"snubbed" equalTo:[NSNumber numberWithBool:YES]];
        int snubbed = [snubbedQuery countObjects];
        [snubbedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
            } else {
                // error
            }
        }];
        self.statusLabel.text = [NSString stringWithFormat:@"Favored by %i, snubbed by %i user(s)", favored, snubbed];
        NSLog(@"Favored %i, snubbed %i", favored, snubbed);
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
