//
//  PZLoaderView.h
//  Pocketz
//
//  Created by Jimmy Xu on 6/16/16.
//  Copyright © 2016 Pocketz World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZLoaderView : UIView

-(id)initWithTintColor:(UIColor*)tintColor;

-(void)animate;
-(void)stop;

@end
