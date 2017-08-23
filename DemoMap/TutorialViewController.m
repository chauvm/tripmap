//
//  TutorialViewController.m
//  DemoMap
//
//  Created by Anh Huynh on 6/19/15.
//  Copyright (c) 2015 Stark Industry. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialChildViewController.h"

@interface TutorialViewController (){
    NSArray *_pageTitles;
    NSArray *_pageContents;
}

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.title = @"StripMapp Tutorial";
    
    
    _pageTitles = @[@"StripMapp Features",
                    @"Stations List",
                    @"Station Information",
                    @"Tips",
                    @"Leaving tips",
                    @"Viewing Tips",
                    @"Change Tip Status"];
    
    _pageContents = @[@"StripMapp lists subway lines, and station including 5 cities in two countries. We use Google transit feed data, GTFS, to present users with a list of lines and stations. We enable users to also leave tips at each station to aid others in navigating that station.\nThere are 3 main tabs in the app. Tap the lines tab to explore cities and lines. Check out the trip planning feature available from the location tab, and manage our account from the settings tab.",
                      @"From the lines tab, select a city, a line, then a line direction.\nThe resulting page shows all the stations on that line, as well as transfers available at each station.\nTapping Reverse button will reverse the display order of the stations.\nTapping the station name will show additional station information. Tapping the transfer information area will display a list of available transfers at that station.",
                      @"Tap on a station to view its details.\nOnce here, you can view and leave tips for each line direction or  main station, view wheelchair accessibility information, service alerts, next train times, and available connections. You can also open Uber from StripMapp.\nCurrently, alerts, schedule information, and wheelchair access information is available for Boston only. We are working to add this information to other cities in a next release.",
                      @"Each station has three tips areas, including one for each direction, and one for the main station. You can flag a tip for moderation. You can view tips according to the priority status you assign, and according to the category given by the tip's creator.\nPriority status includes favored, neutral, and snubbed. All tips by you will automatically be your favored list.\nTip categories are navigation, warning, and recommendation.",
                      @"You can leave tips from either the station information page, or the view tips page.\nTap on the 'enter tip here' edit field to edit it.\nType your text. VoiceOver users can use a two finger double tap to start and stop dictation. Alternatively, you can tap the dictate button from its usual location on the left of the spacebar.\nChoose a category for your tip from a picker item. You can flick up and down inside the picker item to switch between uncategorized, navigation, warning, and recommendation.\nFinally, tap the submit button.",
                      @"Tips are station and direction-specific.\nYou will make choices on two pickers, the first picker selection toggles between favored, neutral, and snubbed tips. The second picker toggles between navigation, warning, recommendation, and uncategorized.\nVoiceOver users  flick up and down inside the picker items after flicking to them.\nYou can see tips after tapping the view tips button.",
                      @"You can change the priority status of any tips between favored, neutral, and snubbed.",
                      ];
    
    
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    TutorialChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (TutorialChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    

    if (([_pageTitles count] == 0) || (index >= [_pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TutorialChildViewController *childViewController = [[TutorialChildViewController alloc] initWithNibName:@"TutorialChildViewController" bundle:nil];
    childViewController.index = index;
    
    childViewController.titleText = _pageTitles[index];
    childViewController.content = _pageContents[index];
    
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialChildViewController *)viewController index];
    
    
    index++;
    
    if (index == [_pageTitles count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return [_pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
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
