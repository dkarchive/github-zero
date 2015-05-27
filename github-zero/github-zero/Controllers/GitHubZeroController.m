//
//  GitHubZeroController.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "GitHubZeroController.h"

// Api
#import "Api.h"

// Categories
#import "UIView+DK.h"
#import "UIImage+Octions.h"

// Controllers
#import "RepoController.h"

// Defines
#import "GZDefines.h"

// Libs
#import "CRToast.h"
#import "GitHubOAuthController.h"
#import "GithubZeroKeys.h"
#import "TOWebViewController.h"

// Models
#import "Event.h"
#import "Notification.h"

// Views
#import "GZCell.h"

@interface GitHubZeroController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic) NSInteger page;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) NSDate *lastUpdate;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIBarButtonItem *signinButton;
@property (nonatomic, strong) UIBarButtonItem *signoutButton;

@property (nonatomic, strong) UIView *headerView;
@end

@implementation GitHubZeroController

NSString *oAuthProvider = @"github-web";
NSString *oAuthScope = @"user notifications repo";

NSString *ud_AccessToken = @"ud_AccessToken";
NSString *ud_UserName = @"ud_UserName";
NSString *ud_LastUpdate = @"ud_LastUpdate";

NSInteger gz_eventsPageSize = 30;
NSInteger gz_rowHeight = 60;
CGFloat gz_headerViewAnimationDuration = 0.7;
NSString *gz_signoutText = @"Sign Out";

NS_ENUM(NSInteger, GZSectionType) {
    GZSectionTypeNotification,
    GZSectionTypeEvent,
    GZSectionTypeCount,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notifications = [[NSArray alloc] init];
    self.events  = [[NSArray alloc] init];
    self.headerView = [[UIView alloc] init];
    UIButton *githubButton = [[UIButton alloc] init];
    self.dataSource = @[
                        self.notifications,
                        self.events,
                        ];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self.view addSubview:self.activityIndicator];
    [self addAndAnimateHeaderView];
    [self.headerView addSubview:githubButton];
    
    self.page = 1;
    
    self.activityIndicator.frame = CGRectMake(0, 0, 30, 30);
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.activityIndicator.center = self.tableView.center;
    self.activityIndicator.hidesWhenStopped = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = gz_rowHeight;
    
    CGRect frame = self.view.bounds;
    frame.size.height = 200;
    self.headerView.frame = frame;
    
    githubButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    githubButton.frame = self.headerView.bounds;
    UIImage *githubImage = [UIImage octicon_imageWithIcon:@"MarkGithub" backgroundColor:[UIColor whiteColor] iconColor:[UIColor lightGrayColor] iconScale:1 andSize:CGSizeMake(100, 100)];
    [githubButton setImage:githubImage forState:UIControlStateNormal];
    [githubButton addTarget:self action:@selector(actionSignin) forControlEvents:UIControlEventTouchUpInside];
    githubButton.adjustsImageWhenHighlighted = NO;
    
    // load token and username
    self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:ud_AccessToken];
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:ud_UserName];
    
    if (self.accessToken) {
        self.navigationItem.rightBarButtonItem = self.signoutButton;
        
        [[Api sharedInstance] initWithToken:self.accessToken];
        
        [self.activityIndicator startAnimating];
        [self getData];
        
        [self setupRefreshControl];
    }
    else {
        self.navigationItem.rightBarButtonItem = self.signinButton;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"GitHub Zero";
}

- (void)viewWillDisappear:(BOOL)animated {
    self.title = @"";
    
    [super viewWillDisappear:animated];
}

#pragma mark - Private

- (void)actionAvatar:(id)sender {
    GZCell *cell = [sender dk_firstSuperviewOfClass:[GZCell class]];
    NSString *url = cell.item.userUrl;
    if (url) {
        [self showWebControllerWithUrlString:url];
    }
}

- (void)actionSignin {
    GithubZeroKeys *keys = [[GithubZeroKeys alloc] init];
    NSString *kClientId = keys.gitHubAPIClientID;
    NSString *kClientSecret = keys.gitHubAPIClientSecret;
    
    GitHubOAuthController *oAuthController = [[GitHubOAuthController alloc] initWithClientId:kClientId clientSecret:kClientSecret scope:@"user notifications repo" success:^(NSString *accessToken, NSDictionary *raw) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.signoutButton;
        
        self.accessToken = accessToken;
        
        [[Api sharedInstance] initWithToken:self.accessToken];
        
        [[Api sharedInstance] getUserWithSuccess:^(NSString *username, NSDictionary *raw) {
            self.userName = username;
            
            // save token and username
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.accessToken forKey:ud_AccessToken];
            [defaults setObject:self.userName forKey:ud_UserName];
            [defaults synchronize];
            
            [self getData];
            
            [self setupRefreshControl];
        } failure:nil];
    } failure:nil];
    
    [oAuthController showModalFromController:self];
}

- (void)actionSignout {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:gz_signoutText otherButtonTitles: nil];
    [sheet showInView:self.view];
}

- (void)addAndAnimateHeaderView {
    self.headerView.alpha = 0;
    self.tableView.tableHeaderView = self.headerView;

    [UIView animateWithDuration:gz_headerViewAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.headerView.alpha = 1;
    } completion:nil];
}

- (void)clearData {
    self.page = 1;
    self.events = @[];
    self.notifications = @[];
    self.dataSource = @[
                        self.notifications,
                        self.events,
                        ];
    [self.tableView reloadData];
}

- (void)getData {
    [self clearData];
    
    [[Api sharedInstance] getNotificationsWithSuccess:^(NSArray *notifications) {
        [UIView animateWithDuration:gz_headerViewAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.headerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.tableView.tableHeaderView = nil;
            self.headerView.alpha = 1;
        }];
        
        __block NSArray *blockNotifications = notifications;
        
        [[Api sharedInstance] getEventsForUsername:self.userName page:self.page success:^(NSArray *events) {
            [self.activityIndicator stopAnimating];
            
            self.notifications = blockNotifications;

            if ((blockNotifications.count==0) && (events.count==0)) {
                events = [Event noEvents];
            }
            
            self.events = events;
            
            self.dataSource = @[
                                self.notifications,
                                self.events
                                ];
            
            // get last update
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            self.lastUpdate = [defaults objectForKey:ud_LastUpdate];
            
            [self.tableView reloadData];
            
            // save last update
            [defaults setObject:[NSDate date] forKey:ud_LastUpdate];
            [defaults synchronize];
        } failure:^(NSError *error) {
            NSLog(@"get data events error: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"get data notifications error: %@", error);
    }];
    
    [self.refreshControl endRefreshing];
}

- (void)getEventsForPage:(NSInteger)page {
    [[Api sharedInstance] getEventsForUsername:self.userName page:self.page success:^(NSArray *events) {
        
        //        NSLog(@"page %@, loaded %@ events", @(page), @(events.count));
        
        if (events.count==0)
            return;
        
        NSMutableArray *list = self.events.mutableCopy;
        
        [list addObjectsFromArray:events];
        
        self.events = list.copy;
        
        self.dataSource = @[
                            self.notifications,
                            self.events
                            ];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"get events for page: %@, error: %@", @(self.page), error);
    }];
}

- (void)showWebControllerWithUrlString:(NSString *)urlString {
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURLString:urlString];
    webViewController.showLoadingBar = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getData) forControlEvents:UIControlEventValueChanged];
}

- (UIBarButtonItem *)signinButton {
    if (!_signinButton) {
        _signinButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(actionSignin)];
    }
    
    return _signinButton;
}

- (UIBarButtonItem *)signoutButton {
    if (!_signoutButton) {
        _signoutButton = [[UIBarButtonItem alloc] initWithTitle:gz_signoutText style:UIBarButtonItemStylePlain target:self action:@selector(actionSignout)];
    }
    
    return _signoutButton;
}

#pragma mark - UITableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *list = self.dataSource[section];
    id <DataSource> item = list.firstObject;
    
    if (section==0) {
        if (self.notifications.count==0)
            return @"";
        
        return [NSString stringWithFormat:@"Notifications — %@", item.timeAgo];
    }
    
    if (self.events.count==0)
        return @"";
    
    return [NSString stringWithFormat:@"Events — %@", item.timeAgo];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return GZSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *list = self.dataSource[section];
    return list.count;
}

NSString *cellId = @"cellId";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GZCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[GZCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    //load more
    if (indexPath.row == ((self.page) * (gz_eventsPageSize - 10))) {
        self.page++;
        [self getEventsForPage:self.page];
    }
    
    NSArray *list = self.dataSource[indexPath.section];
    id <DataSource> item = list[indexPath.row];
    
    [cell setItem:item lastUpdate:self.lastUpdate];
    [cell.avatarImageButton addTarget:self action:@selector(actionAvatar:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *list = self.dataSource[indexPath.section];
    id <DataSource> item = list[indexPath.row];
    
    NSString *destination = @"repo";
    if ([destination isEqualToString:@"repo"]) {
        if (!item.url) {
            NSDictionary *options = @{
                                      kCRToastTextKey : @"Private repos are not supported",
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor lightGrayColor],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastNotificationTypeKey: @(CRToastTypeNavigationBar),
                                      };

            if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
                [CRToastManager showNotificationWithOptions:options completionBlock:nil];
            }
            return;
        }
                
        [self showWebControllerWithUrlString:item.url];
        
        if ([item isKindOfClass:[Notification class]]) {
            Notification *notification = (Notification *)item;
            [[Api sharedInstance] markNotificationAsReadWithThreadsUrl:notification.threads success:^(BOOL status) {                
                NSMutableArray *notifications = self.notifications.mutableCopy;
                [notifications removeObject:item];
                self.notifications = notifications.copy;
                self.dataSource = @[
                                    self.notifications,
                                    self.events,
                                    ];
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                NSLog(@"mark as read error %@", error);
            }];
        }
    }
    
    //    RepoController *repoController = [[RepoController alloc] initWithItem:item];
    //    [self.navigationController pushViewController:repoController animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *list = self.dataSource[indexPath.section];
//    id <DataSource> item = list[indexPath.row];
//
//    //TODO: get attributedString
//
//    return rowHeight;
//}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        [self clearData];
        
        self.refreshControl = nil;
        
        [self addAndAnimateHeaderView];
        
        self.navigationItem.rightBarButtonItem = self.signinButton;
        
        //clear user default keys
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:ud_AccessToken];
        [defaults removeObjectForKey:ud_UserName];
        [defaults synchronize];
    }
}

@end
