//
//  GitHubZeroController.h
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kCloseSafariViewController = @"kCloseSafariViewController";

static NSString *ud_AccessToken = @"ud_AccessToken";
static NSString *ud_UserName = @"ud_UserName";

@interface GitHubZeroController : UITableViewController

- (void)getData;

@end

