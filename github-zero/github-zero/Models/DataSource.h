//
//  DataSource.h
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

@import UIKit;

// Categories
#import "NSString+Emojize.h"

@protocol DataSource <NSObject>

@property (nonatomic, strong) NSString *avatarUrlString;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSAttributedString *title;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *repoName;

@property (nonatomic, strong) NSString *timeAgo;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *userUrl;

/**
 Property to use in dummy events (no events).
 */
@property (nonatomic) BOOL dummy;

+ (NSArray *)newEventsFromResponse:(NSArray *)response;

//- (UIColor *)colorForDate:(NSDate *)date;

@end
