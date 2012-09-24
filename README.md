# About this class

This class is a helper to **add KVO using blocks** to make it easier to use and make your code more readable.

Associate a Objective-C block to a keyPath, and the block will be executed each time the value of the KeyPath is changed.

This class uses KVO to observe the keyPath value changes of course, but allow you to **implement a separate behavior for each observed keyPath** and implement the action **in a dedicated block**.

This way you can **avoid the need to centralize all the actions in the `-(void)observeValueForKeyPath:ofObject:change:context:` method** and the need to make the series of `isEqualToString:` tests to determine the action depending on the keyPath.

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
