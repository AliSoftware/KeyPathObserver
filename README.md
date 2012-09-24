# About this class

This class is a helper to **add KVO using blocks** to make it easier to use and make your code more readable.

Associate a Objective-C block to a keyPath, and **your block will be executed each time the value of the KeyPath is changed** to let you do whatever you want.
And **no need for `removeObserver:forKeyPath:` anymore** either!

_This class uses KVO to observe the keyPath value changes of course, but allow you to **implement a separate behavior for each observed keyPath** and implement the action **in a dedicated block**.
This way you can **avoid the need to centralize all the actions in the `-(void)observeValueForKeyPath:ofObject:change:context:` method** and the need to make the series of `isEqualToString:` tests to determine the action depending on the keyPath._

# Usage examples

Example 1: observing a CGRect property

    [[KeyPathObserver observerForObject:self]
     onKeyPathValueChange:@"frame"
     execute:^(id obj, NSString* kp, id old, id new)
     {
        if (![old isEqual:new])
        {
          NSLog(@"The frame changed from %@ to %@", old, new);
        } else {
          NSLog(@"The frame property was reaffected to the same CGRect value %@", new);
          CGRect newFrame = [new CGRectValue];
          ...
        }
     }];

Example 2: Observing an UIColor object and using a composite keyPath

    [[KeyPathObserver observerForObject:self]
     onKeyPathValueChange:@"view.backgroundColor"
     execute:^(id obj, NSString* kp, id old, id new)
     {
        if (old != new)
        {
          NSLog(@"The view background color has been changed");
        }
     }];

# Additional notes

The `[KeyPathObserver observerForObject:object]` method only creates a unique `KeyPathObserver` instance per object being observed.

This means that calling `[KeyPathObjserver observerForObject:obj]` multiple times or at various locations in the code will always return the same `KeyPathObserver` for the same `obj` instance,
allowing you to add multiple blocks to various keyPaths on the same object without any problem (and without a `KeyPathObserver` being allocated for each different keyPath of the same object).

As the `KeyPathObserver` is associated to the observed object (using ObjC's associative references), it is automatically deallocated when the observed object is deallocated too,
**ensuring that every observer block that was added (using `KeyPathObserver`) to the object during its lifetime will automatically be removed when the observed object is deallocated**.
You thus don't need to perform any `removeObserver:` call or whatsoever to remove your observers, everything is done automagically! :)

