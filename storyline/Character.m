//
//  Character.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "Character.h"

@implementation Character

-(id)initFromDict:(NSDictionary*)dict {
    
    self = [super init];
    if(self) {
        self.name = dict[@"name"];
        self.characterID = dict[@"id"];
        self.isLocal = [dict[@"is_local"] boolValue];
    }
    return self;
}

@end
