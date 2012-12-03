//
//  OGAtomicSerializedArrayTests.m
//  OGAtomicSerializedArrayTests
//
//  Created by Art Gillespie on 12/3/12.
//  Copyright (c) 2012 Origami Labs. All rights reserved.
//

#import "OGAtomicSerializedArrayTests.h"
#import "OGAtomicSerializedArray.h"

NSURL *applicationSupportURL() {
    NSArray *pathURLs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSCAssert(0 != [pathURLs count], @"No urls returned for application support directory");
    NSURL *pathURL = pathURLs[0];
    [[NSFileManager defaultManager] createDirectoryAtURL:pathURL withIntermediateDirectories:YES attributes:nil error:nil];
    return pathURL;
}

NSString *testPath() {
    return [[applicationSupportURL() path] stringByAppendingPathComponent:@"test.array"];
}

@implementation OGAtomicSerializedArrayTests

- (void)setUp {

}

- (void)tearDown {
    // get rid of the serialized file
    [OGAtomicSerializedArray purgeAtomicSerializedArrayAtPath:testPath() purgeFromDisk:YES];
}

- (void)testSerialization {
    OGAtomicSerializedArray *array = [OGAtomicSerializedArray atomicSerializedArrayWithPath:testPath()];
    GHAssertNotNil(array, @"couldn't create atomic array for path: %@", testPath());
    [array addObjectAndSerialize:@"String One"];
    GHAssertEquals((NSUInteger)1, [array count], @"Expected array count of 1, got: %d", [array count]);
    GHAssertEqualStrings(@"String One",[array objectAtIndex:0], @"Expected 'String One' in index [0]");

    // we're violating the black box (and atomicity) here by checking the serialized array directly
    // don't do this in normal usage. We're just testing to ensure the array was written out
    // correctly.
    GHAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testPath()], @"No serialized array at: %@", testPath());
    NSArray *fileArray = [NSArray arrayWithContentsOfFile:testPath()];
    GHAssertNotNil(fileArray, @"Couldn't load array from file");
    GHAssertEquals((NSUInteger)1, [fileArray count], @"Expected 1 element in fileArray");
    GHAssertEqualStrings(@"String One", [array objectAtIndex:0], @"Expected 'String One' in index [0] of fileArray");
}

- (void)testEquality {
    OGAtomicSerializedArray *array = [OGAtomicSerializedArray atomicSerializedArrayWithPath:testPath()];
    GHAssertNotNil(array, @"couldn't create atomic array for path: %@", testPath());
    OGAtomicSerializedArray *array2 = [OGAtomicSerializedArray atomicSerializedArrayWithPath:testPath()];
    GHAssertTrue(array == array2, @"Expected pointer equality for arrays at the same path");
}

- (void)testRemoveObject {
    OGAtomicSerializedArray *array = [OGAtomicSerializedArray atomicSerializedArrayWithPath:testPath()];
    GHAssertNotNil(array, @"couldn't create atomic array for path: %@", testPath());
    [array addObjectAndSerialize:@"String One"];
    [array addObjectAndSerialize:@"String Two"];
    GHAssertEquals((NSUInteger)2, [array count], @"Expected array count of 2, got: %d", [array count]);
    GHAssertEqualStrings(@"String One",[array objectAtIndex:0], @"Expected 'String One' in index [0]");
    [array removeObjectAtIndexAndSerialize:0];
    GHAssertEquals((NSUInteger)1, [array count], @"Expected array count of 1, got: %d", [array count]);
    GHAssertEqualStrings(@"String Two",[array objectAtIndex:0], @"Expected 'String Two' in index [0]");
    [array removeObjectAndSerialize:@"String Two"];
    GHAssertEquals((NSUInteger)0, [array count], @"Expected array count of 1, got: %d", [array count]);
}

@end
