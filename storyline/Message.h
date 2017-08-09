//
//  Message.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Message : NSObject

-(id)initFromDict:(NSDictionary*)dict;

@property (nonatomic) int typingDelay;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *characterID;

@property (nonatomic) BOOL batteryLow;

@end
