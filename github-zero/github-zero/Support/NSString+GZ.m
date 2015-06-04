//
//  NSString+GZ.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/15/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "NSString+GZ.h"
#import "NSDateFormatter+DK.h"

@implementation NSString (GZ)

- (NSString *)convertApiUrl{
    NSString *temp = self;
    temp = [temp stringByReplacingOccurrencesOfString:@"api." withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"/repos" withString:@""];
    return temp;
}

+ (NSString *)timeAgoForString:(NSString *)string {
    NSDateFormatter *formatter = [NSDateFormatter posix];
    
    NSDate *date = [formatter dateFromString:string];
    NSTimeInterval seconds = [date timeIntervalSinceNow];
    
    seconds = fabs(seconds);
    seconds = ceil(seconds);
    if (seconds < 60)
        return [NSString stringWithFormat:@"%@sec ago", @(seconds)];
    
    NSInteger minutes = seconds/60;
    if (minutes<60)
        return [NSString stringWithFormat:@"%@min ago", @(minutes)];
    
    NSInteger hours = minutes / 60;
    if (hours<24)
        return [NSString stringWithFormat:@"%@hr ago", @(hours)];

    NSInteger days = hours / 24;
    return [NSString stringWithFormat:@"%@d ago", @(days)];
}

@end
