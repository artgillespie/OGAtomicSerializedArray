OGAtomicSerializedArray
=======================

OGAtomicSerializedArray provides a simple abstraction for a threadsafe
serialized array. Use it when you need to be 100% sure that changes to an array
will be persisted between runs of your app.

## Example

For example, suppose you need to keep track of in-flight photo uploads to a
server. When you fire off your upload, store the photo's information in an
OGAtomicSerializedArray. When the upload has completed successfully, remove the
associated information from the array. If your app quits unexpectedly, any
unfinished uploads' information will be loaded into the array the next time
your app launches and you can restart the uploads.

## Usage

```objc

/*
 * Get the array instance associated with `[self uploadArrayPath`] e.g.,
 * <Library>/<Application Support>/uploads.array
 */
OGAtomicSerializedArray *array = [OGAtomicSerializedArray atomicSerializedArrayWithPath:[self uploadArrayPath]];
/*
 * Store something in the array and write the array to disk.
 */
[array addObjectAndSerialize:inflightObject];

...

/*
 * Remove the object
 */

[array removeObjectAndSerialize:inflightObject];

```

## TODO

* Write up explanation/simple usage in README.md

