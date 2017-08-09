//
//  StoryProtocol.h
//  storyline
//
//  Created by Jimmy Xu on 11/8/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConversationMarker;

@protocol StoryProtocol <NSObject>

-(void)openStoryWithDict:(NSDictionary*)dict;
-(void)openStoryWithMarker:(ConversationMarker*)marker;
-(void)showStore;

-(void)setGradientViewColor:(UIColor*)color;

@end
