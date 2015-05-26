//
//  NSDateFormatter+DK.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/13/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "NSDateFormatter+DK.h"

@implementation NSDateFormatter (DK)

+ (NSDateFormatter *)posix {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    return formatter;
}

@end
