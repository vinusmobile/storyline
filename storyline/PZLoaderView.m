//
//  PZLoaderView.m
//  Pocketz
//
//  Created by Jimmy Xu on 6/16/16.
//  Copyright © 2016 Pocketz World. All rights reserved.
//

#import "PZLoaderView.h"

@interface PZLoaderView () {
    UIActivityIndicatorView *loaderImage;
}

@end

@implementation PZLoaderView

-(id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 28, 34)];
    if (self) {
        loaderImage = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:loaderImage];
    }
    return self;
}

-(id)initWithTintColor:(UIColor*)tintColor {
    self = [self init];
    if (self) {
        loaderImage.tintColor = tintColor;
    }
    return self;
}

-(void)animate {
    [loaderImage startAnimating];
}

-(void)stop {
    [loaderImage stopAnimating];
}

@end
