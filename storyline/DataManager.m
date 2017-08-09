//
//  DataManager.m
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "DataManager.h"
#import <CoreData/CoreData.h>
#import "RMStore.h"
#import "AppDelegate.h"
#import "RMAppReceipt.h"

NSString *const S3BucketName = @"storyline-assets";
NSString *const S3CDNPath = @"https://s3.amazonaws.com";

@implementation DataManager

+ (DataManager*)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark -
+ (NSString*)appVersion {
    static NSString *versionNumber;
    if (!versionNumber) {
        versionNumber = [NSString stringWithFormat:@"i.%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    }
    return versionNumber;
}

+ (NSString*)buildVersion {
    static NSString *buildNumber;
    if (!buildNumber) {
        buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    }
    return buildNumber;
}

#pragma mark - IAPs
-(void)requestIAPs {
    NSMutableSet *products = [NSMutableSet set];
    for(NSDictionary *iapDict in [DataManager getIAPArray]) {
        [products addObject:iapDict[@"iap_id"]];
    }
    
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"Products loaded");
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
    }];
}

+(NSArray*)getIAPArray {
    static NSArray *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @[
                 @{@"image":@"batterysale1", @"iap_id":@"storyline_1month_trial"},
                 @{@"image":@"batterysale2", @"iap_id":@"storyline_1week_notrial"},
                 @{@"image":@"batterysale4", @"iap_id":@"storyline_1year"},
                 ];
    });
    return inst;
}

+(BOOL)isSubscriptionActive {
    RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
    
    NSArray *subscriptionArray = [DataManager getIAPArray];
    for(NSDictionary *dict in subscriptionArray) {
        NSString *productID = dict[@"iap_id"];
        
        if([receipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:productID forDate:[NSDate date]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Battery
+ (NSTimeInterval)rechargeTime {
    return 2700;
}

+ (BOOL)waitingOnBattery {
    if(![GVUserDefaults standardUserDefaults].lowBatteryStartDate)
        return NO;
    
    NSTimeInterval secondsLeft = [DataManager rechargeTime] + [[GVUserDefaults standardUserDefaults].lowBatteryStartDate timeIntervalSinceNow];
    if(secondsLeft <= 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSDate*)lowBatteryStartDate {
    return [GVUserDefaults standardUserDefaults].lowBatteryStartDate;
}

+ (void)setLowBatteryStartDate:(NSDate *)lowBatteryStartDate {
    [GVUserDefaults standardUserDefaults].lowBatteryStartDate = lowBatteryStartDate;
    [appDelegate cancelLocalNotificationsWithId:@"batteryTimer"];
    
    if(lowBatteryStartDate) {
        [appDelegate scheduleLocalNotificationWithMessage:@"Your Storyline battery's fully charged! Come back to continue your story." afterTimeInterval:[self rechargeTime] notifierId:@"batteryTimer" userInfo:nil];
    }
}

+ (int)batteryChargeAmount {
    return [[GVUserDefaults standardUserDefaults].batteryChargeAmount intValue];
}

+ (void)setBatteryChargeAmount:(int)batteryChargeAmount {
    [GVUserDefaults standardUserDefaults].batteryChargeAmount = [NSNumber numberWithInt:batteryChargeAmount];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyWalletChanged object:nil];
}

@end
