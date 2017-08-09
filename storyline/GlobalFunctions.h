//
//  GlobalFunctions.h
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    // returns the time left from seconds eg. 5h 10m = 5 hours 10 minutes left = 18600s
    STTimeDisplayFormatConcise = 0, // default
    
    // returns just the first part of Concise
    STTimeDisplayFormatMinimal,
    
    // returns minimal spelled out
    STTimeDisplayFormatExpanded,
    
    // returns a differnt format of time left from seconds. eg. 10:59 for 10 mins 59 seconds
    STTimeDisplayFormatClock,
    
    STTimeDisplayFormatVerbose
} STTimeDisplayFormat;


@interface GlobalFunctions : NSObject

+ (NSString*)getIntegerStringDelimitedByCommas:(NSInteger)intValue;
+ (NSString*)getIntegerStringFor:(NSInteger)intValue useKAt:(int)kLimit useMAt:(int)mLimit useBAt:(int)bLimit;
+ (NSString*)timeLeftStringFromSecondsLeft:(NSTimeInterval)secondsLeft;
+ (NSString*)timeLeftStringFromSecondsLeft:(NSTimeInterval)secondsLeft format:(STTimeDisplayFormat)format;

@end
