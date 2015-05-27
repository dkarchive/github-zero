//
//  Api.h
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Api : NSObject

+ (instancetype)sharedInstance;

- (void)initWithToken:(NSString *)token;

//- (void)getEventsForUsername:(NSString *)username success:(void (^)(NSArray *events))success failure:(void (^)(NSError *error))failure;

- (void)getEventsForUsername:(NSString *)username page:(NSInteger)page success:(void (^)(NSArray *events))success failure:(void (^)(NSError *error))failure;

//- (void)getMergeStatusForPullRequest:(NSString *)pullRequest success:(void (^)(BOOL status))success failure:(void (^)(NSError *error))failure;

- (void)getNotificationsWithSuccess:(void (^)(NSArray *notifications))success failure:(void (^)(NSError *error))failure;

- (void)getReposWithSearch:(NSString *)search success:(void (^)(NSArray *repos))success failure:(void (^)(NSError *error))failure;

- (void)getUserWithSuccess:(void (^)(NSString *username, NSDictionary *raw))success failure:(void (^)(NSError *error))failure;

- (void)markNotificationAsReadWithThreadsUrl:(NSString *)threads success:(void (^)(BOOL status))success failure:(void (^)(NSError *error))failure;

@end
