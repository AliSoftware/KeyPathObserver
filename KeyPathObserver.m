//
//  KeyPathObserver.m
//
//  Created by Olivier Halligon on 24/09/12.
//
//

#import "KeyPathObserver.h"
#import <objc/runtime.h>


@interface KeyPathObserver : NSObject
+(KeyPathObserver*)observerForObject:(id)object;
@property(nonatomic, retain) NSMutableDictionary* blocksMappings;
@property(nonatomic, assign) id targetObject;
@end



@implementation NSObject (KeyPathObserver)

-(void)onKeyPathValueChange:(NSString*)keyPath execute:(KeyPathObserverActionBlock)block
{
    [[KeyPathObserver observerForObject:self] onKeyPathValueChange:keyPath execute:block];
}

-(NSArray*)observedKeyPaths
{
    return [[KeyPathObserver observerForObject:self].blocksMappings allKeys];
}


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
            observer = [[[self alloc] init] autorelease];
            observer.blocksMappings = [NSMutableDictionary dictionary];
            observer.targetObject = object;
            objc_setAssociatedObject(object, &kKeyPathObserverContext, observer, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return observer;
}

-(void)onKeyPathValueChange:(NSString*)keyPath execute:(KeyPathObserverActionBlock)block
{
    if (block)
    {
        NSMutableArray* blocks = [self.blocksMappings objectForKey:keyPath];
        if (!blocks)
        {
            blocks = [NSMutableArray array];
            [self.blocksMappings setObject:blocks forKey:keyPath];
            NSKeyValueObservingOptions options = (NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew);
            [self.targetObject addObserver:self forKeyPath:keyPath options:options context:&kKeyPathObserverContext];
        }
        [blocks addObject:[[block copy] autorelease]];
    } else {
        [self.targetObject removeObserver:self forKeyPath:keyPath context:&kKeyPathObserverContext];
        [self.blocksMappings removeObjectForKey:keyPath];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup & Teardown


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
    NSMutableArray* blocks = [self.blocksMappings objectForKey:keyPath];
    for(KeyPathObserverActionBlock block in blocks)
    {
        id old = [change objectForKey:NSKeyValueChangeOldKey];
        id new = [change objectForKey:NSKeyValueChangeNewKey];
        block(object, keyPath, old, new);
    }
}

@end