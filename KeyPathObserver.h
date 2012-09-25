//
//  KeyPathObserver.h
//
//  Created by Olivier Halligon on 24/09/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^KeyPathObserverActionBlock)(id obj, NSString* keyPath, id oldVal, id newVal);


/*
 * Typical usage:
 *
 * [self onKeyPathValueChange:@"title" execute:^(id obj, NSString* kp, id old, id new)
 *  {
 *      // Code to execute when the self.title property is assigned a new value
 *      if (old != new)
 *      {
 *         NSLog(@"title changed from %@ to %@", old, new);
 *      }
 *  }];
 *
 */

@interface NSObject (KeyPathObserver)

//! Add a block to execute when a given keyPath is affected.
//! * Calling this method multiple times adds blocks to the list of blocks to execute: alls the blocks added will be executed in turn.
//! * Calling this method with a nil block removes all the blocks associated with the keyPath
//! @note affecting the same value as the already affected value for a keyPath will still trigger the block execution
//!       You may want to check if the "old" and "new" values are different before doing some action, with "old != new" for objects
//!       or (![old isEqual:new]) for NSValue objects encapsulating structs or atomic types (like CGRects for example)
-(void)onKeyPathValueChange:(NSString*)keyPath execute:(KeyPathObserverActionBlock)block;


//! List the keyPaths actually registered for observation by the KeyPathObserver object
//! @note this will not list the keyPath obsvered by calling -addObserver:forKeyPath:options:context: directly
//!       and for those you manage the KVO yourself, but only the keypath observed by the KeyPathObserver itself.
@property(nonatomic, copy, readonly) NSArray* observedKeyPaths;

@end
