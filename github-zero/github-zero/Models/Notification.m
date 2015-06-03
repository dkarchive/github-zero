//
//  Notification.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "Notification.h"

// Categories
#import "NSDateFormatter+DK.h"
#import "NSDictionary+GZ.h"
#import "NSString+GZ.h"
#import "UIColor+DK.h"
#import "UIImage+Octions.h"

//#import "Api.h"

@interface Notification ()
@property (nonatomic, strong) NSDictionary *repository;
@property (nonatomic, strong) NSDictionary *subject;
@property (nonatomic, strong) NSString *updatedAt;

@property (nonatomic, strong) NSDictionary *raw;
@end

@implementation Notification
@synthesize avatarUrlString, date, destination, dummy, title, image, repoName, timeAgo, type, url, userUrl;

+ (NSArray *)newEventsFromResponse:(NSArray *)response {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in response) {
        Notification *notification = [self newNotificationFromResponse:dictionary];
        [list addObject:notification];
    }
    return list.copy;
}

+ (Notification *)newNotificationFromResponse:(NSDictionary *)response {
    Notification *notification = [[Notification alloc] init];

    notification.repository = response[@"repository"];
    notification.subject = response[@"subject"];
    notification.updatedAt = response[@"updated_at"];
    
    notification.raw = response;
    
    return notification;
}

- (NSString *)avatarUrlString {
    NSDictionary *owner = self.repository[@"owner"];
    return owner[@"avatar_url"];
}

//- (UIColor *)colorForDate:(NSDate *)dateB {
//    return [UIColor colorForDate:self.date fromDate:dateB];
//
//}

- (NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter posix];
    return [formatter dateFromString:self.updatedAt];
}

- (DestinationType)destination {
    NSNumber *private = self.repository[@"private"];
    if (private.integerValue)
        return DestinationTypePrivate;
    
    return DestinationTypeWeb;
}

- (NSString *)type {
    return self.subject[@"type"];
}

- (NSAttributedString *)title {
    NSString *temp = self.subject[@"title"];
    
    temp = [temp emojizedString];
    NSDictionary *attributes = [NSDictionary gz_titleAttributes];
    return [[NSAttributedString alloc] initWithString:temp attributes:attributes];
}

//- (NSString *)subtitle {
//    return [NSString stringWithFormat:@"%@ on %@",
//            self.timeAgo,
//            self.repoName
//            ];
//}

- (NSString *)repoName {
    return self.repository[@"full_name"];
}

- (NSString *)timeAgo {
    return [NSString timeAgoForString:self.updatedAt];
}

- (UIImage *)image {
    NSString *icon;
    
    if ([self.type isEqualToString:@"PullRequest"]) {
        icon = @"GitPullRequest";
    }
    
    if ([self.type isEqualToString:@"Issue"]) {
        icon = @"IssueOpened";
    }
    
    UIColor *iconColor = [UIColor grayColor];
    
    if (icon)
        return [UIImage octicon_imageWithIcon:icon backgroundColor:[UIColor clearColor] iconColor:iconColor  iconScale:1 andSize:CGSizeMake(20, 20)];
    
    icon = @"MarkGithub";
    NSLog(@"notification raw=%@", self.raw);
    NSLog(@"notification type=%@", self.type);
    return [UIImage octicon_imageWithIcon:icon backgroundColor:[UIColor clearColor] iconColor:iconColor  iconScale:1 andSize:CGSizeMake(20, 20)];
}

- (NSString *)url {
    NSString *repo = self.subject[@"url"];
    repo = [repo stringByReplacingOccurrencesOfString:@"api." withString:@""];
    repo = [repo stringByReplacingOccurrencesOfString:@"repos/" withString:@""];
    
    return repo;
}

- (NSString *)userUrl {
    NSDictionary *owner = self.repository[@"owner"];
    NSString *temp = owner[@"url"];
    temp = [temp stringByReplacingOccurrencesOfString:@"api." withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"/users" withString:@""];
    
    return temp;
}

//- (void)getImageWithSuccess:(void (^)(UIImage *))success2 {
//    NSString *type = self.subject[@"type"];
//
//    NSLog(@"notification type=%@", type);
//
//    NSString *icon;
//
//    if ([type isEqualToString:@"PullRequest"]) {
//        icon = @"GitPullRequest";
//    }
//
//    if ([type isEqualToString:@"Issue"]) {
//        icon = @"IssueOpened";
//
//        if (success2) {
//
//            success2( [UIImage octicon_imageWithIcon:icon backgroundColor:[UIColor clearColor] iconColor:[UIColor greenColor]  iconScale:1 andSize:CGSizeMake(20, 20)] );
//
//
//
//        }
//        return;
//    }
//
//
//    [[Api sharedInstance] getMergeStatusForPullRequest:self.mergeUrlString success:^(BOOL status) {
//        //        NSLog(@"merge status = %@", @(status));
//
//        if (icon) {
//            UIColor *color = [UIColor greenColor];
//            if (status) {
//                color = [UIColor purpleColor];
//            }
//
//
//            if (success2) {
//                success2( [UIImage octicon_imageWithIcon:icon backgroundColor:[UIColor clearColor] iconColor:color  iconScale:1 andSize:CGSizeMake(20, 20)] );
//            }
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"get merge status error %@", error);
//    }];
//
//
//
//    //    return nil;
//}

#pragma mark - Private
//
//- (NSString *)mergeUrlString {
//    return self.subject[@"url"];
//}
//

- (NSString *)threads {
    return self.raw[@"url"];
}

@end
