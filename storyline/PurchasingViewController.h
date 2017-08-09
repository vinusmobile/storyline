//
//  PurchasingViewController.h
//  storyline
//
//  Created by Jimmy Xu on 11/8/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PurchasingViewControllerProtocol <NSObject>
-(void)purchaseComplete;
@end

@interface PurchasingViewController : UIViewController
@property (nonatomic, weak) id<PurchasingViewControllerProtocol> delegate;

@end
