//
//  PZLoadingViewController.h
//  Pocketz
//
//  Created by Jimmy Xu on 5/20/16.
//  Copyright © 2016 Pocketz World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZLoadingViewController : UIViewController

@property (nonatomic) BOOL dismissing;
@property (nonatomic) BOOL disableAutoDismiss;

+(PZLoadingViewController*)currentVC;

+(void)show:(NSString*)message presentingController:(UIViewController*)controller animated:(BOOL)animated withCompletion:(void (^ __nullable)(void))completion;
+(void)updateMessage:(NSString*)message;
+(void)dismiss:(BOOL)animated withCompletion:(void (^ __nullable)(void))completion;

@end
