//
//  Message.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "Message.h"

@implementation Message

-(id)initFromDict:(NSDictionary*)dict {
    self = [super init];
    
    if(self) {
        self.text = dict[@"text"];
        self.characterID = dict[@"sender_id"];
        self.typingDelay = [dict[@"delay"] intValue];
        self.batteryLow = [dict[@"battery"] boolValue];
    }
    
    return self;
}

@end
