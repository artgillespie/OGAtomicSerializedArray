//
//  OGAtomicSerializedArray.h
//  OGAtomicSerializedArray
//
//  Created by Art Gillespie on 10/4/12.
//  Copyright (c) 2012 Origami Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const OGAtomicSerializedArrayDeserializationException;
extern NSString *const OGAtomicSerializedArraySerializationException;

@interface OGAtomicSerializedArray : NSObject <NSFastEnumeration>

/**
 * The array will be serialized to `path` on each write. If a file already
 * exists at `path`, it will be deserialized into this array before returning.
 */
+ (OGAtomicSerializedArray *)atomicSerializedArrayWithPath:(NSString *)path;

/**
 * Remove the atomic array at `path` from memory. If `purgeFromDisk` is 
 * `YES`, will also delete the serialized file. Returns `YES` if `path` referred
 * to an in-memory array and the purge was successful.
 */
+ (BOOL)purgeAtomicSerializedArrayAtPath:(NSString *)path purgeFromDisk:(BOOL)purgeFromDisk;

/**
 * Create a new atomic serialized array at `path`
 */
- (id)initWithPath:(NSString *)path;

- (void)addObjectAndSerialize:(id)object;

- (void)addObjectsFromArrayAndSerialize:(NSArray *)array;

- (void)removeObjectAtIndexAndSerialize:(NSUInteger)index;

- (void)removeObjectAndSerialize:(id)obj;

- (void)removeAllObjectsAndSerialize;

- (NSUInteger)count;

- (id)objectAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

@end
