//
//  RepoController.m
//  github-zero
//
//  Created by Daniel Khamsing on 4/7/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "RepoController.h"

// Libs
#import "CXCountDownLabel.h"

@interface RepoController ()
@property (nonatomic, strong) id<DataSource> item;

@property (nonatomic, strong) CXCountDownLabel *starCounter;
@end

@implementation RepoController

- (instancetype)initWithItem:(id<DataSource>)item {
    self = [super init];
    if (!self)
        return nil;
    
    self.item = item;
    
    self.starCounter = [[CXCountDownLabel alloc] init];
    
    [@[self.starCounter,
       ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           [self.view addSubview:obj];
       }];
    
    self.starCounter.font = [UIFont systemFontOfSize:60];
    self.starCounter.textColor = [UIColor whiteColor];
    
    return self;
}

- (void)setItem:(id<DataSource>)item {
    _item = item;
    
    //    NSLog(@"set item: %@ %@", item, item.url);
    
    NSURL *url = [NSURL URLWithString:item.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 99)];
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if ([indexSet containsIndex:statusCode] && data) {
            NSError *parseError = nil;
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
            if (dictionary) {
                //                NSLog(@"dict = %@", dictionary);
                
                self.title = dictionary[@"name"];
                
                NSNumber *number = dictionary[@"stargazers_count"];
                if (number.integerValue>0) {
                    [self.starCounter setStartNumber:0 endNumber:number.integerValue countDownHandeler:nil];
                    [self.starCounter start];
                }
            }
            else {
                
                NSLog(@"errors %@", parseError);
            }
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.starCounter.frame = CGRectMake(0, 80, CGRectGetMaxX(self.view.frame), 50);
}

@end
