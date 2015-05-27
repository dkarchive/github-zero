//
//  Repository.m
//  github-zero
//
//  Created by Daniel Khamsing on 5/27/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "Repository.h"

@interface Repository ()
@property (nonatomic, strong) NSDictionary *raw;
@end

@implementation Repository

+ (NSArray *)newRepositoriesFromResponse:(NSDictionary *)response {
//    NSLog(@"repository response=%@", response);
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSDictionary *item in response[@"items"]) {
        Repository *repo = [self newRepositoryFromResponse:item];
        [list addObject:repo];
    }
    return list.copy;
}

#pragma mark - Private

+ (Repository *)newRepositoryFromResponse:(NSDictionary *)response {
    Repository *repo = [[Repository alloc] init];
    repo.name = response[@"name"];
    
    {
        NSString *temp = response[@"url"];
        temp = [temp stringByReplacingOccurrencesOfString:@"api." withString:@""];
        temp = [temp stringByReplacingOccurrencesOfString:@"repos/" withString:@""];
        repo.url = temp;
    }
    
    {
        NSNumber *temp = response[@"stargazers_count"];
        repo.stars = temp;
    }
    
    repo.raw = response;
    
    return repo;
}

@end
