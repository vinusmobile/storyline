//
//  RowCollectionTableViewCell.h
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryProtocol.h"

@interface RowCollectionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<StoryProtocol> delegate;

@property (nonatomic, strong) NSArray *contentArray;

@end
