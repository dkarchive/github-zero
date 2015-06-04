//
//  NSString+GZ.h
//  github-zero
//
//  Created by Daniel Khamsing on 4/15/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GZ)

- (NSString *)convertApiUrl;

+ (NSString *)timeAgoForString:(NSString *)string;

@end
