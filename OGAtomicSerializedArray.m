//
//  OGAtomicSerializedArray.m
//  OGAtomicSerializedArray
//
//  Created by Art Gillespie on 10/4/12.
//  Copyright (c) 2012 Origami Labs, Inc. All rights reserved.
//

#import "OGAtomicSerializedArray.h"

@implementation OGAtomicSerializedArray {
    __strong NSString *_path;
    __strong NSMutableArray *_mutableArray;
}

static NSMutableDictionary *OGGlobalSerializedArraysDictionary = nil;

+ (OGAtomicSerializedArray *)atomicSerializedArrayWithPath:(NSString *)path {
    if (nil == OGGlobalSerializedArraysDictionary) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            OGGlobalSerializedArraysDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        });
    }
    // on the off chance that more than one thread calls this with the same path
    // at the same time, serialize access to `OGAtomicSerializedArraysDictionary`
#ifndef __clang_analyzer__
    // The static analyzer doesn't understand that we'll never get here
    // with a nill value for `OGGlobalSerializedArraysDictionary` and so flags
    // this code as `Nil value used as mutex for @synchronized`
    //
    // #ifdef'ing the synchronization out for analyzer runs eliminates the warning.
    // see http://clang-analyzer.llvm.org/faq.html#exclude_code
    @synchronized (OGGlobalSerializedArraysDictionary) {
#endif
        // we only keep one in-memory representation for each path, so if
        // we already have one in the global dictionary, return that.
        OGAtomicSerializedArray *atomicArray = [OGGlobalSerializedArraysDictionary objectForKey:path];
        if (nil != atomicArray) {
            return atomicArray;
        }
        // the atomic array for this path isn't in memory ...
        atomicArray = [[OGAtomicSerializedArray alloc] initWithPath:path];
        [OGGlobalSerializedArraysDictionary setObject:atomicArray forKey:path];
        return atomicArray;
#ifndef __clang_analyzer__
    } // end @synchronized
#endif
}

+ (BOOL)purgeAtomicSerializedArrayAtPath:(NSString *)path purgeFromDisk:(BOOL)purgeFromDisk {
    OGAtomicSerializedArray *array = [OGGlobalSerializedArraysDictionary objectForKey:path];
    if (nil == array) {
        return NO;
    }
    [OGGlobalSerializedArraysDictionary removeObjectForKey:path];
    if (NO == purgeFromDisk) {
        return YES;
    }
    NSError *error;
    return [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (nil != self) {
        _path = path;
        _mutableArray = [NSMutableArray arrayWithCapacity:2];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
            // if we have an existing serialization, update using it
            [self updateFromPath];
        } else {
            // create the intermediate directories above `_path` if needed.
            NSError *error = nil;
            if (NO == [[NSFileManager defaultManager] fileExistsAtPath:[_path stringByDeletingLastPathComponent]]) {
                if (NO == [[NSFileManager defaultManager] createDirectoryAtPath:[_path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
                    @throw [NSException exceptionWithName:@"OGAtomicSerializedArrayInitializationException"
                                                   reason:[NSString stringWithFormat:@"Couldn't Create Directory At Path: %@", [_path stringByDeletingLastPathComponent]]
                                                                            userInfo:nil];
                }
            }
        }
    }
    return self;
}

- (NSUInteger)count {
    return [_mutableArray count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return _mutableArray[index];
}

- (void)addObjectAndSerialize:(id)object {
    @synchronized(self) {
        [_mutableArray addObject:object];
        [self serialize];
    }
}

- (void)addObjectsFromArrayAndSerialize:(NSArray *)array {
    @synchronized(self) {
        [_mutableArray addObjectsFromArray:array];
        [self serialize];
    }
}

- (void)removeObjectAtIndexAndSerialize:(NSUInteger)index {
    @synchronized(self) {
        [_mutableArray removeObjectAtIndex:index];
        [self serialize];
    }
}

- (void)removeObjectAndSerialize:(id)obj {
    @synchronized(self) {
        [_mutableArray removeObject:obj];
        [self serialize];
    }
}

- (void)removeAllObjectsAndSerialize {
    @synchronized(self) {
        [_mutableArray removeAllObjects];
        [self serialize];
    }
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_mutableArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Private Methods

/**
 * Private: Overwrite our contents with the array serialized at `_path`
 */
- (void)updateFromPath {
    @synchronized(self) {
        [_mutableArray removeAllObjects];
        NSArray *tmp = [NSMutableArray arrayWithContentsOfFile:_path];
        if (nil == tmp) {
            @throw [NSException exceptionWithName:@"OGAtomicSerializedArrayDeserializationException" reason:[NSString stringWithFormat:@"Couldn't read the OGAtomicSerializedArray at %@", _path] userInfo:nil];
        }
        [_mutableArray addObjectsFromArray:tmp];
    }
}

- (void)serialize {
    if(NO == [_mutableArray writeToFile:_path atomically:YES]) {
        @throw [NSException exceptionWithName:@"OGAtomicSerializedArraySerializationException" reason:[NSString stringWithFormat:@"Couldn't write the OGAtomicSerializedArray at %@", _path] userInfo:nil];
    }    
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    return [_mutableArray indexOfObjectPassingTest:predicate];
}
@end
