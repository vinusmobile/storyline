//
//  ChatThreadViewController.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"
#import "StoryProtocol.h"

@class ConversationMarker;

@interface ChatThreadViewController : UIViewController

@property (nonatomic, strong) Conversation *conversation;
@property (nonatomic, weak) id<StoryProtocol> delegate;

- (BOOL)showingCover;

- (void)showStoryCover;
- (void)showStoryWithDict:(NSDictionary*)storyDict;
- (void)showStoryWithMarker:(ConversationMarker*)marker;

@end
