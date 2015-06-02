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
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    id appearance = [UINavigationBar appearance];
    
    [appearance setTintColor:[UIColor grayColor]];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:gzFont size:18] };
    [appearance setTitleTextAttributes:attributes];
    
    NSDictionary *attributes2 = @{ NSFontAttributeName : [UIFont fontWithName:gzFont size:14],
                                   NSForegroundColorAttributeName : [UIColor grayColor],
                                   };
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes2 forState:UIControlStateNormal];
    
    UIScreen *screen = [UIScreen mainScreen];
    
    self.window = [[UIWindow alloc] initWithFrame:screen.bounds];
    
    GitHubZeroController *viewController = [[GitHubZeroController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.swiper = [[SloppySwiper alloc] initWithNavigationController:navigationController];
    navigationController.delegate = self.swiper;
    
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
