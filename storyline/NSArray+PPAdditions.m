//
//  NSArray+PPAdditions.m
//  PennyPop
//
//  Created by Osei Poku on 7/19/12.
//  Copyright (c) 2012 MIR Partners. All rights reserved.
//

#import "NSArray+PPAdditions.h"

@implementation NSArray (PPAdditions)

-(NSDictionary*)dictionaryWithKeysFromProperty:(NSString*)keyPath {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        [dict setObject:obj forKey:[obj valueForKeyPath:keyPath]];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSArray*)arrayByApplyingBlock:(id (^)(id))func {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        [array addObject:func(obj)];
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray*)arrayByApplyingSelector:(SEL)selector {
    return [self arrayByApplyingBlock:^id(id obj) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [obj performSelector:selector];
#pragma clang diagnostic pop
    }];
}

-(NSArray*)arrayByCreatingClass:(Class)clazz initSelector:(SEL)selector {
    NSAssert([clazz instancesRespondToSelector:selector], @"This class %@ does not respond to %@", NSStringFromClass(clazz), NSStringFromSelector(selector));
    return [self arrayByApplyingBlock:^id(id obj) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [[clazz alloc] performSelector:selector withObject:obj];
#pragma clang diagnostic pop
    }];
}

-(NSArray*)arrayByApplyingClassSelector:(SEL)selector class:(Class)clazz {
    NSAssert([clazz respondsToSelector:selector], @"This class %@ does not respond to class method %@", NSStringFromClass(clazz), NSStringFromSelector(selector));
    return [self arrayByApplyingBlock:^id(id obj) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [clazz performSelector:selector withObject:obj];
#pragma clang diagnostic pop
    }];
}

- (id)randomObject {
    return [self objectAtIndex:(arc4random()%[self count])];
}

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
@end

@implementation NSMutableArray (PPAdditions)

- (void)shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}
@end
