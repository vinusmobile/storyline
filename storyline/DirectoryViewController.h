//
//  DirectoryViewController.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryProtocol.h"

@interface DirectoryViewController : UIViewController

@property (nonatomic, weak) id<StoryProtocol> delegate;

-(void)configureWithTag:(NSString*)tag withStories:(NSArray<NSDictionary*>*)stories;

-(void)directoryDidAppear;

@end
