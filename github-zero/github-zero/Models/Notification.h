//
//  Notification.h
//  github-zero
//
//  Created by Daniel Khamsing on 4/3/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import "DataSource.h"

@interface Notification : NSObject <DataSource>

- (NSString *)threads;

@end
