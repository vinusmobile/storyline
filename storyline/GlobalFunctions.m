//
//  GlobalFunctions.m
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "GlobalFunctions.h"

static NSNumberFormatter *formatter = nil;
static NSNumberFormatter *currencyFormatter = nil;
static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *serverDateFormatter = nil;

@implementation GlobalFunctions

+(void)initialize {
    [super initialize];
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    serverDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [serverDateFormatter setLocale:enLocale];
    //UTC Format
    [serverDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS ZZZ"];
    [serverDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [self updateLocales];
}

+ (void)updateLocales {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[NSLocale preferredLanguages][0]];
    dateFormatter.locale = locale;
    //  overwrite for am pm symbols for russian language
    if ([locale.localeIdentifier isEqualToString:@"ru"] || [locale.localeIdentifier isEqualToString:@"de"]) {
        [dateFormatter setAMSymbol:@"AM"];
        [dateFormatter setPMSymbol:@"PM"];
    } else {
        [dateFormatter setAMSymbol:nil];
        [dateFormatter setPMSymbol:nil];
    }
}

+(NSString*)getIntegerStringDelimitedByCommas:(NSInteger)intValue {
    NSString *stringToReturn = [formatter stringFromNumber:[NSNumber numberWithInteger:intValue]];
    if (!stringToReturn) stringToReturn = @"0";
    return stringToReturn;
}

+(NSString*)getIntegerStringFor:(NSInteger)intValue useKAt:(int)kLimit useMAt:(int)mLimit useBAt:(int)bLimit {
    NSString *returnString = @"";
    if (intValue >= bLimit) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%ldB", (long)(intValue/1000000000)];
        returnString = string;
    } else if (intValue >= mLimit) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%ldM", (long)(intValue/1000000)];
        returnString = string;
    } else if (intValue >= kLimit) {
        NSMutableString *string = [NSMutableString stringWithFormat:@"%ldK", (long)(intValue/1000)];
        returnString = string;
    } else {
        returnString = [NSString stringWithFormat:@"%ld", (long)intValue];
    }
    
    return returnString;
}

+ (NSString*)timeLeftStringFromSecondsLeft:(NSTimeInterval)secondsLeft {
    return [self timeLeftStringFromSecondsLeft:secondsLeft format:STTimeDisplayFormatConcise];
}

+ (NSString*)timeLeftStringFromSecondsLeft:(NSTimeInterval)secondsLeft format:(STTimeDisplayFormat)format {
    NSInteger monthsLeft = secondsLeft / (30*60*60*24);
    NSInteger daysLeft = secondsLeft / (60*60*24);
    NSInteger hoursLeft = (NSInteger)(secondsLeft / (60*60));
    NSInteger minsLeft = (NSInteger)(secondsLeft / 60) % 60;
    NSInteger secLeft = (NSInteger)secondsLeft % 60;
    
    NSString *timeLeftString = @"";
    switch (format) {
        case STTimeDisplayFormatVerbose: {
            hoursLeft = hoursLeft % 24;
            if (daysLeft > 0) {
                minsLeft = 0;
                secLeft = 0;
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%@ ",[NSString stringWithFormat:@"%ldd", (long)daysLeft]];
            }
            
            if (hoursLeft > 0 || daysLeft > 0) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%@ ", [NSString stringWithFormat:@"%ldh", (long)hoursLeft]];
            }
            
            if (minsLeft > 0 || (hoursLeft > 0 && daysLeft == 0)) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%@ ", [NSString stringWithFormat:@"%ldm", (long)minsLeft]];
            }
            
            if (daysLeft == 0) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%lds", (long)secLeft];
            }
            
            //  added to remove unwanted space characters from begining and end of string
            timeLeftString = [timeLeftString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            break;
        }
        case STTimeDisplayFormatClock: {
            if (hoursLeft > 0) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%02ld:", (long)hoursLeft];
            }
            timeLeftString = [timeLeftString stringByAppendingFormat:@"%02ld:%02ld", (long)minsLeft, (long)secLeft];
            break;
        }
        case STTimeDisplayFormatMinimal: {
            hoursLeft = hoursLeft % 24;
            if (monthsLeft > 1) {
                timeLeftString = [NSString stringWithFormat:@"%ld months", (long)monthsLeft];
            } else if(monthsLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%ld month", (long)monthsLeft];
            } else if (daysLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%ldd", (long)daysLeft];
            } else if (hoursLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%ldh", (long)hoursLeft];
            } else if (minsLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%ldm", (long)minsLeft];
            } else if (secLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%lds", (long)secLeft];
            } else {
                timeLeftString = [NSString stringWithFormat:@"%ds", 0];
            }
            break;
        }
        case STTimeDisplayFormatExpanded: {
            hoursLeft = hoursLeft % 24;
            if (monthsLeft > 1) {
                timeLeftString = [NSString stringWithFormat:@"%ld months", (long)monthsLeft];
            } else if(monthsLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%ld month", (long)monthsLeft];
            } else if (daysLeft > 0) {
                if(daysLeft == 1) {
                    timeLeftString = [NSString stringWithFormat:@"%ld day", (long)daysLeft];
                } else {
                    timeLeftString = [NSString stringWithFormat:@"%ld days", (long)daysLeft];
                }
            } else if (hoursLeft > 0) {
                if(hoursLeft == 1) {
                    timeLeftString = [NSString stringWithFormat:@"%ld hour", (long)hoursLeft];
                } else {
                    timeLeftString = [NSString stringWithFormat:@"%ld hours", (long)hoursLeft];
                }
            } else if (minsLeft > 0) {
                if(minsLeft == 1) {
                    timeLeftString = [NSString stringWithFormat:@"%ld minute", (long)minsLeft];
                } else {
                    timeLeftString = [NSString stringWithFormat:@"%ld minutes", (long)minsLeft];
                }
            } else if (secLeft > 0) {
                timeLeftString = [NSString stringWithFormat:@"%ld seconds", (long)secLeft];
            } else {
                timeLeftString = [NSString stringWithFormat:@"%d second", 0];
            }
            break;
        }
        default:
        case STTimeDisplayFormatConcise: {
            hoursLeft = hoursLeft % 24;
            if (daysLeft > 0) {
                minsLeft = 0;
                secLeft = 0;
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%@ ",[NSString stringWithFormat:@"%ldd", (long)daysLeft]];
            }
            
            if (hoursLeft > 0 || daysLeft > 0) {
                secLeft = 0;
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%@ ", [NSString stringWithFormat:@"%ldh", (long)hoursLeft]];
            }
            
            if (minsLeft > 0 || (hoursLeft > 0 && daysLeft == 0)) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%@ ", [NSString stringWithFormat:@"%ldm", (long)minsLeft]];
            }
            
            if (minsLeft > 0 && (daysLeft == 0 && hoursLeft == 0)) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%lds", (long)secLeft];
            }
            
            if (secLeft > 0 && (minsLeft == 0 && hoursLeft == 0)) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%lds", (long)secLeft];
            }
            if ([timeLeftString isEqualToString:@""]) {
                timeLeftString = [timeLeftString stringByAppendingFormat:@"%ds", 0];
            }
            //  added to remove unwanted space characters from begining and end of string
            timeLeftString = [timeLeftString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            break;
        }
    }
    
    return timeLeftString;
    
}


@end
