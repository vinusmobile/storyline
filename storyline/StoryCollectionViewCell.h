//
//  StoryCollectionViewCell.h
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConversationMarker;

@interface StoryCollectionViewCell : UICollectionViewCell

- (void)configureWithDict:(NSDictionary*)dict;
- (void)configureWithMarker:(ConversationMarker*)marker;

@end
