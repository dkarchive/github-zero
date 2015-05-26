//
//  Event.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "Event.h"

// Categories
#import "NSDateFormatter+DK.h"
#import "NSDictionary+GZ.h"
#import "NSString+DK.h"
#import "NSString+GZ.h"
#import "UIColor+DK.h"
#import "UIImage+Octions.h"

@interface Event ()
@property (nonatomic, strong) NSDictionary *actor;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSDictionary *payload;
@property (nonatomic, strong) NSDictionary *repo;

@property (nonatomic, strong) NSDictionary *raw;
@property (nonatomic, strong) NSString *icon;
@end

@implementation Event
@synthesize avatarUrlString, date, dummy, title, image, repoName, timeAgo, type, url, userUrl;

+ (NSArray *)newEventsFromResponse:(NSArray *)response {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in response) {
        Event *event = [self initWithDictionary:dictionary];
        [list addObject:event];
    }
    
    return list.copy;
}

+ (Event *)initWithDictionary:(NSDictionary *)dictionary {
    Event *event = [[Event alloc] init];
    
    event.actor = dictionary[@"actor"];
    event.createdAt = dictionary[@"created_at"];
    event.payload = dictionary[@"payload"];
    event.repo = dictionary[@"repo"];
    event.type = dictionary[@"type"];
    
    event.raw = dictionary;
    
    return event;
}

+ (NSArray *)noEvents {
    Event *dummy = [[Event alloc] init];
    dummy.dummy = YES;
    return @[ dummy ];
}

#pragma mark - Public

- (NSString *)avatarUrlString {
    return self.actor[@"avatar_url"];
}

//- (UIColor *)colorForDate:(NSDate *)dateB {
//    return [UIColor colorForDate:self.date fromDate:dateB];
//}

- (NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter posix];
    return [formatter dateFromString:self.createdAt];
}

- (UIImage *)image {
    if (self.icon)
        return [UIImage octicon_imageWithIcon:self.icon backgroundColor:[UIColor clearColor] iconColor:[UIColor lightGrayColor] iconScale:1 andSize:CGSizeMake(20, 20)];
    
    return nil;
}

- (NSString *)repoName {
    return self.repo[@"name"];
}

- (NSAttributedString *)title {
    NSString *temp;
    
    if ([self.type isEqualToString:@"MemberEvent"]) {
        self.icon = @"MarkGithub";
        temp = [NSString stringWithFormat:@"%@ added %@ to %@",
                self.actor[@"login"],
                self.payload[@"member"][@"login"],
                self.repo[@"name"]];
    }
    
    if ([self.type isEqualToString:@"IssuesEvent"]) {
        self.icon = @"IssueOpened";
        temp = [NSString stringWithFormat:@"%@ %@ issue %@",
                self.actor[@"login"],
                self.payload[@"action"],
                self.payload[@"issue"][@"title"]];
    }
    
    NSString *commitText;
    if ([self.type isEqualToString:@"PushEvent"]) {
        self.icon = @"GitCommit";
        NSArray *commits = self.payload[@"commits"];
        commitText = [NSString stringWithFormat:@"%@ %@",
                      @(commits.count),
                      [@"commit" dk_pluralize:commits.count]
                      ] ;
        temp = [NSString stringWithFormat:@"%@ pushed %@ to %@",
                self.actor[@"login"],
                commitText,
                self.branch];
    }
    
    if (
        ([self.type isEqualToString:@"ForkEvent"]) ||
        ([self.type isEqualToString:@"CreateEvent"]) ||
        ([self.type isEqualToString:@"DeleteEvent"])
        )
    {
        self.icon = @"GitBranch";
        
        if ([self.type isEqualToString:@"ForkEvent"])
            temp = [NSString stringWithFormat:@"%@ forked", self.actor[@"login"]];
        
        if ([self.type isEqualToString:@"CreateEvent"]) {
            if (self.branch.length==0) {
                temp = [NSString stringWithFormat:@"%@ created a new repo",
                        self.actor[@"login"]
                        ];
            }
            else {
                temp = [NSString stringWithFormat:@"%@ created branch %@",
                        self.actor[@"login"],
                        self.branch
                        ];
            }
        }
        
        if ([self.type isEqualToString:@"DeleteEvent"]) {
            temp = [NSString stringWithFormat:@"%@ deleted branch %@",
                    self.actor[@"login"],
                    self.branch
                    ];
        }
    }
    
    if ([self.type isEqualToString:@"PullRequestEvent"]) {
        NSNumber *merge = self.payload[@"pull_request"][@"merged"];
        temp = [NSString stringWithFormat:@"%@ %@ %@ (#%@ pull request)",
                self.actor[@"login"],
                merge.integerValue ? @"merged" : @"opened",
                self.payload[@"pull_request"][@"title"],
                self.payload[@"number"]
        ];
        
        
        self.icon = @"GitPullRequest";
    }
    
    if (
        ([self.type isEqualToString:@"IssueCommentEvent"]) ||
        ([self.type isEqualToString:@"PullRequestReviewCommentEvent"]) ||
        ([self.type isEqualToString:@"CommitCommentEvent"])
        ) {
        self.icon = @"CommentDiscussion";
        temp = [NSString stringWithFormat:@"%@ said %@ ", self.actor[@"login"], self.comment ];
    }
    
    if ([self.type isEqualToString:@"WatchEvent"]) {
        self.icon = @"Star";
        temp = [NSString stringWithFormat:@"%@ starred", self.actor[@"login"]];
    }
    
    if (!temp) {
        NSLog(@"type = %@", self.type);
        NSLog(@"raw = %@", self.raw);
        self.icon = @"MarkGithub";
        
        temp = [NSString stringWithFormat:@"%@ did something", self.actor[@"login"]];
    }
    
    if (self.dummy)
        temp = @"No Events";
    
    temp = [temp emojizedString];
    
    NSDictionary *attributes = [NSDictionary gz_titleAttributes];
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:temp attributes:attributes];
    
    [self applyStyleToText:temp match:self.actor[@"login"]  attributed:attributed];
    
    [self applyStyleToText:temp match:self.branch attributed:attributed];
    
    [self applyStyleToText:temp match:commitText attributed:attributed];
    
    [self applyStyleToText:temp match:self.payload[@"pull_request"][@"title"] attributed:attributed];
    
    [self applyStyleToText:temp match:self.payload[@"issue"][@"title"] attributed:attributed];
    
    return attributed;
    
    /*
     https://developer.github.com/v3/activity/events/types/
     
     CommitCommentEvent
     CreateEvent
     DeleteEvent
     DeploymentEvent
     DeploymentStatusEvent
     DownloadEvent
     FollowEvent
     ForkEvent
     ForkApplyEvent
     GistEvent
     GollumEvent
     IssueCommentEvent
     IssuesEvent
     MemberEvent
     MembershipEvent
     PageBuildEvent
     PublicEvent
     PullRequestEvent
     PullRequestReviewCommentEvent
     PushEvent
     ReleaseEvent
     RepositoryEvent
     StatusEvent
     TeamAddEvent
     WatchEvent
     */
}

//- (NSString *)subtitle {
//    return [NSString stringWithFormat:@"%@ on %@",
//            self.timeAgo,
//            self.repoName];
//}

- (NSString *)timeAgo {
    return [NSString timeAgoForString:self.createdAt];
}

- (NSString *)url {
    //    NSLog(@"event raw: %@", self.raw);
    //return self.repo[@"url"];
    
    NSString *htmlUrl = self.payload[@"comment"][@"html_url"];
    if (htmlUrl)
        return htmlUrl;
    
    NSString *destination =
    //    self.repo[@"url"];
    [NSString stringWithFormat:@"https://github.com/%@", self.repo[@"name"]];
    
    return destination;
}

- (NSString *)userUrl {
    NSString *temp = self.actor[@"url"];
    temp = [temp stringByReplacingOccurrencesOfString:@"api." withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"/users" withString:@""];
    return temp;
}

#pragma mark - Private

- (void)applyStyleToText:(NSString *)temp
                   match:(NSString *)match
              attributed:(NSMutableAttributedString*)attributed {
    if (!match)
        return;
    
    NSRange range = [temp rangeOfString:match];
    if (range.location!=NSNotFound) {
        NSDictionary *attributes = [NSDictionary gz_boldAttributes];
        [attributed addAttributes:attributes range:range];
    }
}

- (NSString *)branch {
    NSString *branch = self.payload[@"ref"];
    
    if ([branch isEqual:[NSNull null]])
        return @"";
    
    branch = [branch stringByReplacingOccurrencesOfString:@"refs/heads/" withString:@""];
    return branch;
}

- (NSString *)comment {
    NSDictionary *comment = self.payload[@"comment"];
    NSString *text = comment[@"body"];
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text;
}

@end
