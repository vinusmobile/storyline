//
//  NSArray+PPAdditions.h
//  PennyPop
//
//  Created by Osei Poku on 7/19/12.
//  Copyright (c) 2012 MIR Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (PPAdditions)

// creates a dictionary with the objects in the array as values, using the keypath as keys
-(NSDictionary*)dictionaryWithKeysFromProperty:(NSString*)keyPath;

// returns array containing the results of sending each object in the array the selector as a message
-(NSArray*)arrayByApplyingSelector:(SEL)selector;

// returns an array containing the result of running the block using each object in the array as a parameter
-(NSArray*)arrayByApplyingBlock:(id(^)(id))func;

// returns an array by converting each element in the array by calling an init function with the first parameter being each object in the array
-(NSArray*)arrayByCreatingClass:(Class)clazz initSelector:(SEL)selector;

// returns an array by converting each element in the array by calling a class method with the first parameter being each object in the array
-(NSArray*)arrayByApplyingClassSelector:(SEL)selector class:(Class)clazz;

// get a random object from the array
-(id)randomObject;

- (NSArray *)reversedArray;
@end

@interface NSMutableArray (PPAdditions)

-(void)shuffle;
- (void)reverse;

@end
