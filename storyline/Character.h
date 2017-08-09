//
//  Character.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Character : NSObject

-(id)initFromDict:(NSDictionary*)dict;

@property (nonatomic, strong) NSString *characterID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL isLocal;

@end
