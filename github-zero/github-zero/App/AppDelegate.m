//
//  AppDelegate.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "AppDelegate.h"

// Controllers
#import "GitHubZeroController.h"

// Defines
#import "GZDefines.h"

// Libraries
#import "SloppySwiper.h"

@interface AppDelegate () <UINavigationControllerDelegate>
@property (nonatomic, strong) SloppySwiper *swiper;
@property (nonatomic, strong) GitHubZeroController *zeroController;
@property (nonatomic) BOOL launched;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self applyStyle];
    
    self.launched = YES;
    
    UIScreen *screen = [UIScreen mainScreen];
    
    self.window = [[UIWindow alloc] initWithFrame:screen.bounds];
    
    self.zeroController = [[GitHubZeroController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.zeroController];
    self.swiper = [[SloppySwiper alloc] initWithNavigationController:navigationController];
    navigationController.delegate = self.swiper;
    
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.launched) {
        self.launched = NO;
        return;
    }
    
    // check for last update and initiate refresh
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:ud_LastUpdate];
    NSTimeInterval seconds = [date timeIntervalSinceNow];
    NSInteger minutes = fabs(seconds) / 60;
    if (minutes>4) {
        [self.zeroController getData];
    }
}

#pragma mark - Private

- (void)applyStyle {
    id appearance = [UINavigationBar appearance];
    
    [appearance setTintColor:[UIColor grayColor]];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:gzFont size:18] };
    [appearance setTitleTextAttributes:attributes];
    
    NSDictionary *attributes2 = @{ NSFontAttributeName : [UIFont fontWithName:gzFont size:14],
                                   NSForegroundColorAttributeName : [UIColor grayColor],
                                   };
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes2 forState:UIControlStateNormal];
}

@end
