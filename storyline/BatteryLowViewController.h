//
//  BatteryLowViewController.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol batteryLowProtocol <NSObject>
-(void)batteryRecharged;
@end

@interface BatteryLowViewController : UIViewController

@property (nonatomic, weak) id<batteryLowProtocol> delegate;

@end
