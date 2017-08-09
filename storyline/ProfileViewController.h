//
//  ProfileViewController.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryProtocol.h"

@interface ProfileViewController : UIViewController

@property (nonatomic, weak) id<StoryProtocol> delegate;

@end
