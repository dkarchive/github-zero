//
//  TrendingController.m
//  github-zero
//
//  Created by Daniel Khamsing on 5/27/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "TrendingController.h"

// Api
#import "Api.h"

// Categories
#import "UIImage+Octions.h"

// Defines
#import "GZDefines.h"

// Models
#import "Repository.h"

// Libraries
#import "DKDataCache.h"
#import "TOWebViewController.h"

@interface TrendingCell : UITableViewCell
@property (nonatomic, strong) UILabel *repoLabel;
@property (nonatomic, strong) UIButton *button;
@end

@implementation TrendingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (!self)
        return nil;
    
    //init
    self.button = [[UIButton alloc] init];
    self.repoLabel = [[UILabel alloc] init];
    
    //content
    [self.contentView addSubview:self.repoLabel];
    [self.contentView addSubview:self.button];
    
    //setup
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.repoLabel.font = [UIFont fontWithName:gzFont size:14];
    
    [self.button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont fontWithName:gzFont size:10];
    self.button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    UIImage *starImage = [UIImage octicon_imageWithIcon:@"Star" backgroundColor:[UIColor whiteColor] iconColor:[UIColor grayColor] iconScale:1.0 andSize:CGSizeMake(14, 14)];
    [self.button setImage:starImage forState:UIControlStateNormal];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = 66;
    CGFloat height = self.bounds.size.height;
    CGRect frame = CGRectMake(self.bounds.size.width-width, 0, width, height);
    self.button.frame = frame;
    
    frame.size.width = frame.origin.x;
    frame.origin.x = 16;
    frame.size.width -= frame.origin.x;
    self.repoLabel.frame = frame;
}

@end

@interface TrendingController ()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation TrendingController

NSString *repoData = @"repoData";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Trending";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    NSString *query = @"repositories?sort=stars&order=desc&q=pushed:%3E";
    query = [query stringByAppendingString:today];
    
    id array = [[DKDataCache sharedInstance] dataForKey:repoData];
    if (array) {
        self.dataSource = array;
    }
    else {
        [[Api sharedInstance] getReposWithSearch:query success:^(NSArray *repos) {
            self.dataSource = repos;
            [self.tableView reloadData];
            
            [[DKDataCache sharedInstance] cacheData:(id)repos forKey:repoData];
        } failure:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"repoCell";
    TrendingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[TrendingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    Repository *repo = self.dataSource[indexPath.row];
    cell.repoLabel.text = repo.name;
    [cell.button setTitle:repo.stars.stringValue forState:UIControlStateNormal];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Repository *repo = self.dataSource[indexPath.row];
    NSString *urlString = repo.url;
    
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURLString:urlString];
    webViewController.showLoadingBar = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
