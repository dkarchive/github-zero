//
//  AppDelegate.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "AppDelegate.h"

// Api
#import "Api.h"

// Constants
#import "GZDefines.h"

// Controllers
#import "GitHubZeroController.h"

// Libraries
#import "GitHubOAuthController.h"
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
    
    UINavigationController *navigationController = ({
        self.zeroController = [[GitHubZeroController alloc] initWithStyle:UITableViewStyleGrouped];
        [[UINavigationController alloc] initWithRootViewController:self.zeroController];
    });
    
    self.window = ({
        UIScreen *screen = [UIScreen mainScreen];
        [[UIWindow alloc] initWithFrame:screen.bounds];
    });
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    self.swiper = [[SloppySwiper alloc] initWithNavigationController:navigationController];
    navigationController.delegate = self.swiper;
    
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSString *source = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    if ([source isEqualToString:gh_safariViewService]) {                
        [[GitHubOAuthController sharedInstance] exchangeCodeForAccessTokenInUrl:url success:^(NSString *accessToken, NSDictionary *raw) {
            [[Api sharedInstance] initWithToken:accessToken];
            
            [[Api sharedInstance] getUserWithSuccess:^(NSString *username, NSDictionary *raw) {
                // save token and username
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:accessToken forKey:ud_AccessToken];
                [defaults setObject:username forKey:ud_UserName];
                [defaults synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kCloseSafariViewController object:username];
            } failure:nil];
            
        } failure:nil];
        
        return YES;
    };
    
    return NO;
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
