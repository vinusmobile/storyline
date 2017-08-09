//
//  PPJSONSerialization.m
//  PennyPop
//
//  Created by Jonathan Zhang on 11/20/13.
//  Copyright (c) 2013 MIR Partners. All rights reserved.
//

#import "PPJSONSerialization.h"

@implementation PPJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    if (!data) {
        return nil;
    }
    return [super JSONObjectWithData:data options:opt error:error];
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    if ([self isValidJSONObject:obj]) {
        return [super dataWithJSONObject:obj options:opt error:error];
    } else {
        return nil;
    }
}
@end
