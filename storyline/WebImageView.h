//
//  WebImageView.h
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebImageView : UIImageView

@property (nonatomic, strong) NSURL *url;

-(void)loadImageForURL:(NSString*) url;
-(void)stopLoadingImage;

@end
