//
//  GZCell.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/13/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "GZCell.h"

// Defines
#import "GZDefines.h"

// Support
#import "DKDataCache.h"

@interface GZCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *repoLabel;
@property (nonatomic, strong) UILabel *agoLabel;
@end

@implementation GZCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self)
        return nil;
    
    self.avatarImageButton = [[UIButton alloc] init];
    self.titleLabel = [[UILabel alloc] init];
    self.repoLabel = [[UILabel alloc] init];
    self.agoLabel = [[UILabel alloc] init];
    
    self.agoLabel.textColor = [UIColor grayColor];
    self.agoLabel.font = [UIFont fontWithName:gzFont size:10];
    self.avatarImageButton.layer.cornerRadius = 12;
    self.avatarImageButton.clipsToBounds = YES;
    
    [@[self.avatarImageButton, self.titleLabel, self.agoLabel, self.repoLabel] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [self.contentView addSubview:obj];
        obj.translatesAutoresizingMaskIntoConstraints = NO;
    }];
    
    NSDictionary *metrics = @{
                              @"padLeft":@50,
                              @"pad":@10,
                              @"avatarSize":@(self.avatarImageButton.layer.cornerRadius * 2),
                              };
    NSDictionary *views = @{
                            @"avatar":self.avatarImageButton,
                            @"title":self.titleLabel,
                            @"sub":self.agoLabel,
                            @"repo":self.repoLabel,
                            };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padLeft-[avatar(avatarSize)]-[title]-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padLeft-[sub]-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padLeft-[avatar(avatarSize)]-[repo]-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-pad-[avatar(avatarSize)]-[sub]|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[title][repo][sub]|" options:0 metrics:metrics views:views]];
        
    return self;
}

- (void)setItem:(id<DataSource>)event lastUpdate:(NSDate *)lastUpdate {
    _item = event;
    
    self.titleLabel.attributedText = event.title;
    
    if (event.dummy) { 
        return;
    }
    
    self.agoLabel.text = event.timeAgo;
    self.imageView.image = event.image;
    
    NSString *repoName = [event.repoName substringToIndex: [event.repoName rangeOfString:@"/"].location + 1];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:gzFont size:12],
                                 NSForegroundColorAttributeName:[UIColor blackColor],};
    NSMutableAttributedString *attributedRepoName = [[NSMutableAttributedString alloc] initWithString:event.repoName attributes:attributes];
    [attributedRepoName addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:[event.repoName rangeOfString:repoName]];
    self.repoLabel.attributedText = attributedRepoName;
    
    [self.avatarImageButton setImage:nil forState:UIControlStateNormal];
    
    NSData *data = [[DKDataCache sharedInstance] dataForKey:event.avatarUrlString];
    if (data) {
        [self.avatarImageButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:event.avatarUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            [[DKDataCache sharedInstance] cacheData:data forKey:event.avatarUrlString];
            [self.avatarImageButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }
    }];
    
    //    if (lastUpdate) {
    //        self.titleLabel.textColor = [event colorForDate:lastUpdate];
    //    }
}

@end
