//
//  Conversation.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "Conversation.h"
#import "DataManager.h"
#import "ConversationMarker+CoreDataClass.h"

@implementation Conversation

+(id)deserialize:(NSDictionary*)dict {
    Conversation *convo = [[Conversation alloc] init];
    convo.conversationID = dict[@"id"];
    convo.title = dict[@"title"];
    convo.summary = dict[@"summary"];
    convo.nextDict = dict[@"next"];
    convo.seriesMarker = dict[@"series"];
    
    convo.coverImageURL = dict[@"image_url"];
    convo.readCount = [dict[@"read_count"] intValue];
    
    NSDictionary *authorDict = dict[@"author"];
    convo.authorName = authorDict[@"name"];
    convo.authorID = authorDict[@"id"];
    
    NSArray *msgsArray = [(NSArray*)dict[@"messages"] arrayByCreatingClass:[Message class] initSelector:@selector(initFromDict:)];
    convo.messages = msgsArray;

    NSMutableDictionary *charaDict = [NSMutableDictionary dictionaryWithCapacity:[dict[@"characters"] count]];
    NSArray *array = dict[@"characters"];
    
    for(NSDictionary *dict in array) {
        Character *chara = [[Character alloc] initFromDict:dict];
        [charaDict setObject:chara forKey:chara.characterID];
    }
    convo.characters = charaDict;
    return convo;
}

-(NSString*)authorName {
    if(_authorName) return _authorName;
    return @"Anonymous";
}

-(void)setCurrentReadIndex:(int)currentReadIndex {
    _currentReadIndex = currentReadIndex;
    
    ConversationMarker *marker = [ConversationMarker MR_findFirstByAttribute:@"conversation_id"
                                           withValue:self.conversationID];

    ConversationMarker *aMarker = marker;
    if(!aMarker) {
        aMarker = [ConversationMarker MR_createEntity];
        aMarker.conversation_id = self.conversationID;
        aMarker.image_url = self.coverImageURL;
        aMarker.read_count = self.readCount;
        aMarker.author_id = self.authorID;
        aMarker.author_name = self.authorName;
        aMarker.title = self.title;
        
        if(self.seriesMarker.count == 2) {
            aMarker.series_current = [self.seriesMarker[0] intValue];
            aMarker.series_total = [self.seriesMarker[1] intValue];
        }
    }
    
    aMarker.last_opened = [NSDate date];
    aMarker.index = currentReadIndex;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
