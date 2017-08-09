//
//  PPJSONSerialization.h
//  PennyPop
//
//  Created by Jonathan Zhang on 11/20/13.
//  Copyright (c) 2013 MIR Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPJSONSerialization : NSJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
@end
