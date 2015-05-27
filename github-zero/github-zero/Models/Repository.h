//
//  Repository.h
//  github-zero
//
//  Created by Daniel Khamsing on 5/27/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repository : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *stars;
+ (NSArray *)newRepositoriesFromResponse:(NSDictionary *)response;
@end
