//
//  GVUserDefaults+Storyline.h
//  storyline
//
//  Created by Jimmy Xu on 11/8/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <GVUserDefaults/GVUserDefaults.h>

@interface GVUserDefaults (Storyline)

@property (nonatomic, weak) NSDate *lowBatteryStartDate;
@property (nonatomic, weak) NSNumber *batteryChargeAmount;

@property (nonatomic, weak) NSDate *pushPermissionAsked;
@property (nonatomic, weak) NSDate *pushPermissionGranted;

@end
