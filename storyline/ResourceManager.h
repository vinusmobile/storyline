//
//  ResourceManager.h
//  storyline
//
//  Created by Jimmy Xu on 11/10/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessCallbackType)(BOOL success);
typedef void(^FilePathCallbackType)(NSString *path);

@interface ResourceManager : NSObject

+ (ResourceManager*)sharedInstance;

+ (NSString*) downloadDirectory;

+(void) findPathForConversationID:(NSString*)conversationID complete:(FilePathCallbackType)completeBlock;
+(void) findPathForResource:(NSString*)fileName complete:(FilePathCallbackType)completeBlock;

@end
