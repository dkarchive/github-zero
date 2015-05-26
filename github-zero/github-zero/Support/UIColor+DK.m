//
//  UIColor+DK.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/13/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "UIColor+DK.h"

@implementation UIColor (DK)

+ (UIColor *)colorForDate:(NSDate *)forDate fromDate:(NSDate *)fromDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:
                                    NSCalendarUnitSecond
                                               fromDate:forDate
                                                 toDate:fromDate
                                                options:0];
    
    if (components.second>0)
        return [UIColor lightGrayColor];
    
    return nil;
}
    

@end
