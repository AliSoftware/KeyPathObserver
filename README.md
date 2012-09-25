# About this class

This category helps you **add KVO using blocks** to make it easier to use and make your code more readable.

Associate a Objective-C block to a keyPath, and **your block will be executed each time the value of the KeyPath is changed** to let you do whatever you want.
No need to centralize everything in `-(void)observeValueForKeyPath:ofObject:change:context:`, and **no need for `removeObserver:forKeyPath:` anymore** either
as the observer blocks are automatically removed when the object is deallocated!

# Usage examples

Example 1: observing a CGRect property

    [self onKeyPathValueChange:@"frame"
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

    [self onKeyPathValueChange:@"view.backgroundColor"
     execute:^(id obj, NSString* kp, id old, id new)
     {
        if (old != new)
        {
          NSLog(@"The view background color has been changed");
        }
     }];
