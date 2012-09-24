//
//  KeyPathObserver.m
//
//  Created by Olivier Halligon on 24/09/12.
//
//

#import "KeyPathObserver.h"
#import <objc/runtime.h>



@interface KeyPathObserver ()
-(id)initWithTarget:(id)object;
@property(nonatomic, retain) NSMutableDictionary* blocksMappings;
@property(nonatomic, assign) id targetObject;
@end



@implementation KeyPathObserver
@synthesize blocksMappings = _blocksMappings;
@synthesize targetObject = _targetObject;

static char kKeyPathObserverContext;

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

+(KeyPathObserver*)observerForObject:(id)object
{
    KeyPathObserver* observer = nil;
    if (object)
    {
        observer = (KeyPathObserver*)objc_getAssociatedObject(object, &kKeyPathObserverContext);
        if (!observer)
        {
            observer = [[[self alloc] initWithTarget:object] autorelease];
            objc_setAssociatedObject(object, &kKeyPathObserverContext, observer, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return observer;
}


-(void)onKeyPathValueChange:(NSString*)keyPath execute:(KeyPathObserverActionBlock)block
{
    if (block)
    {
        [self.blocksMappings setObject:[[block copy] autorelease] forKey:keyPath];
        NSKeyValueObservingOptions options = (NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew);
        [self.targetObject addObserver:self forKeyPath:keyPath options:options context:&kKeyPathObserverContext];
    } else {
        [self.targetObject removeObserver:self forKeyPath:keyPath context:&kKeyPathObserverContext];
        [self.blocksMappings removeObjectForKey:keyPath];
    }
}

-(NSArray*)observedKeyPaths
{
    return [self.blocksMappings allKeys];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup & Teardown

-(id)initWithTarget:(id)object
{
    self = [super init];
    if (self)
    {
        self.blocksMappings = [NSMutableDictionary dictionary];
        self.targetObject = object;
    }
    return self;
}

-(void)dealloc
{
    // Remove observers
    NSEnumerator* reverseEnum = [self.blocksMappings.allKeys reverseObjectEnumerator];
    for(NSString* keyPath in reverseEnum)
    {
        [self.targetObject removeObserver:self forKeyPath:keyPath context:&kKeyPathObserverContext];
    }
    [_blocksMappings release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KVO Implementation

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    KeyPathObserverActionBlock block = [self.blocksMappings objectForKey:keyPath];
    if (block)
    {
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        id new = [change objectForKey:NSKeyValueChangeNewKey];
        block(object, keyPath, old, new);
    }
}

@end