//
//  Api.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "Api.h"

// Categories
#import "NSString+DK.h"

// Models
#import "Event.h"
#import "Notification.h"
#import "Repository.h"

@interface Api ()
@property (nonatomic, strong) NSString *token;
@end

NSString *api_url_base = @"https://api.github.com";
NSString *api_url_events = @"https://api.github.com/users/gzUsernamePlaceholder/received_events";
NSString *api_url_notifications = @"https://api.github.com/notifications";
NSString *api_url_notificationsUsernamePlaceholder = @"gzUsernamePlaceholder";
NSString *api_url_search = @"https://api.github.com/search";
NSString *api_url_user = @"https://api.github.com/user";

@implementation Api

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)initWithToken:(NSString *)token {
    [Api sharedInstance].token = token;
}


- (void)getEventsForUsername:(NSString *)username page:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *urlEvents = [api_url_events stringByReplacingOccurrencesOfString:api_url_notificationsUsernamePlaceholder withString:username];
    urlEvents = [urlEvents stringByAppendingFormat:@"?page=%@", @(page)];
    
    [self sendAsynchronousRequestWithUrlString:urlEvents success:^(id response) {
        NSArray *events = [Event newEventsFromResponse:response];
        if (success) {
            success(events);
        }
    } failure:failure];
}

//- (void)getEventsForUsername:(NSString *)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
//    NSString *urlEvents = [api_url_events stringByReplacingOccurrencesOfString:@"USERNAME" withString:username];
//    [self sendAsynchronousRequestWithUrlString:urlEvents success:^(id response) {
//        NSArray *events = [Event newEventsFromResponse:response];
//        if (success) {
//            success(events);
//        }
//    } failure:failure];
//}

//- (void)getMergeStatusForPullRequest:(NSString *)pullRequest success:(void (^)(BOOL))success failure:(void (^)(NSError *))failure {
//    NSString *url = [NSString stringWithFormat:@"%@/merge", pullRequest];
//    [self sendAsynchronousRequestForStatusWithUrlString:url success:success failure:failure];
//}

- (void)getNotificationsWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [self sendAsynchronousRequestWithUrlString:api_url_notifications success:^(id response) {
        NSArray *notifications = [Notification newEventsFromResponse:response];
        if (success) {
            success(notifications);
        }
    } failure:failure];
}

- (void)getReposWithSearch:(NSString *)search success:(void (^)(NSArray *repos))success failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", api_url_search, search];
    
    [self sendAsynchronousRequestWithUrlString:urlString success:^(id response) {
        NSArray *repos = [Repository newRepositoriesFromResponse:response];
        if (success) {
            success(repos);
        }
    } failure:failure];
}

- (void)getUserWithSuccess:(void (^)(NSString *, NSDictionary *))success failure:(void (^)(NSError *))failure {
    [self sendAsynchronousRequestWithUrlString:api_url_user success:^(id response) {
        if (success) {
            success(response[@"login"], response);
        }
    } failure:failure];
}

- (void)markNotificationAsReadWithThreadsUrl:(NSString *)threads success:(void (^)(BOOL status))success failure:(void (^)(NSError *error))failure {
    NSString *urlWithToken = [NSString stringWithFormat:@"%@?access_token=%@", threads, self.token];
    NSURL *url = [NSURL URLWithString:urlWithToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            if (failure) {
                failure(connectionError);
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        //        NSLog(@"mark notification as read.. status code: %@", @(httpResponse.statusCode));
        
        if (httpResponse.statusCode==205) {
            if (success) {
                success(YES);
            }
        }
        else {
            if (success) {
                success(NO);
            }
        }
    }];
}

#pragma mark - Private

//- (void)sendAsynchronousRequestForStatusWithUrlString:(NSString *)urlString success:(void(^)(BOOL status))success failure:(void(^)(NSError *error))failure {
//    NSString *urlWithToken = [NSString stringWithFormat:@"%@?access_token=%@", urlString, self.token];
//    NSURL *URL = [NSURL URLWithString:urlWithToken];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//
//        if (httpResponse.statusCode==204) {
//            if (success) {
//                success(YES);
//            }
//        }
//        else {
//            if (success) {
//                success(NO);
//            }
//        }
//
//        //TODO: failure
//    }];
//}

- (void)sendAsynchronousRequestWithUrlString:(NSString *)urlString success:(void(^)(id response))success failure:(void(^)(NSError *error))failure {
    NSURL *URL = (self.token) ?
    ({
        NSString *symbol = ([urlString dk_containsString:@"?"])?@"&":@"?";
        NSString *urlWithToken = [NSString stringWithFormat:@"%@%@access_token=%@", urlString,
                                  symbol,
                                  self.token
                                  ];
        [NSURL URLWithString:urlWithToken];
    })
    :
    ({
        [NSURL URLWithString:urlString];
    });
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 99)];
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if ([indexSet containsIndex:statusCode] && data) {
            NSError *parseError = nil;
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
            if (dictionary) {
                if (success) {
                    success(dictionary);
                }
            }
            else {
                if (failure) {
                    failure(parseError);
                }
            }
        }
        else {
            if (failure) {
                failure(connectionError);
            }
        }
    }];
}

@end
