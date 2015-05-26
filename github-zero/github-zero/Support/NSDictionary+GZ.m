//
//  NSDictionary+GZ.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/15/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "NSDictionary+GZ.h"

// Defines
#import "GZDefines.h"

@implementation NSDictionary (GZ)

CGFloat gz_titleSize = 16;

+ (NSDictionary *)gz_boldAttributes {
    return @{NSFontAttributeName:[UIFont fontWithName:gzFontBold size:gz_titleSize],
             NSForegroundColorAttributeName:[UIColor blackColor]
             };
}

+ (NSDictionary *)gz_titleAttributes {
    return @{NSFontAttributeName:[UIFont fontWithName:gzFont size:gz_titleSize],
             NSForegroundColorAttributeName:[UIColor grayColor]
             };
}

@end
