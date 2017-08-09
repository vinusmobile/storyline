//
//  DataManager.h
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotifyWalletChanged @"NotifyWalletChanged"

FOUNDATION_EXPORT NSString *const S3BucketName;
FOUNDATION_EXPORT NSString *const S3CDNPath;

@interface DataManager : NSObject

@property (nonatomic, strong) NSArray<NSDictionary*> *directoryStories;

+(DataManager*)sharedInstance;

+ (NSString*)appVersion;
+ (NSString*)buildVersion;

-(void)requestIAPs;
+(NSArray*)getIAPArray;
+(BOOL)isSubscriptionActive;

+ (NSTimeInterval)rechargeTime;

+ (BOOL)waitingOnBattery;
+ (NSDate*)lowBatteryStartDate;
+ (void)setLowBatteryStartDate:(NSDate *)lowBatteryStartDate;
+ (int)batteryChargeAmount;
+ (void)setBatteryChargeAmount:(int)batteryChargeAmount;
@end
