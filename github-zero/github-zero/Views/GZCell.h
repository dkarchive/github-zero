//
//  GZCell.h
//  github-zero
//
//  Created by Daniel Khamsing on 4/13/15.
//  Copyright (c) 2015 dkhamsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"

@interface GZCell : UITableViewCell
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) id <DataSource> item;
- (void)setItem:(id<DataSource>)item lastUpdate:(NSDate *)lastUpdate;
@end
