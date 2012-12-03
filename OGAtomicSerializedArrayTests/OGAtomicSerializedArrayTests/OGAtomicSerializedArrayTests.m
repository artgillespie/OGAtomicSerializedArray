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

@implementation OGAtomicSerializedArrayTests

- (void)testSerialization {
    NSString *arrayPath = [[applicationSupportURL() path] stringByAppendingPathComponent:@"test.array"];
    OGAtomicSerializedArray *array = [OGAtomicSerializedArray atomicSerializedArrayWithPath:arrayPath];
    GHAssertTrue(nil != array, @"couldn't create atomic array for path: %@", arrayPath);
}

@end
