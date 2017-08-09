//
//  Conversation.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Message.h"
#import "Character.h"

@interface Conversation : NSObject

+(id)deserialize:(NSDictionary*)dict;

@property (nonatomic, strong) NSString *conversationID;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *coverImageURL;

@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *authorID;

@property (nonatomic) int readCount;

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSDictionary *characters;

//transient properties
@property (nonatomic) int currentReadIndex;

@property (nonatomic, strong) NSDictionary *nextDict;

@property (nonatomic, strong) NSArray *seriesMarker;

@end
