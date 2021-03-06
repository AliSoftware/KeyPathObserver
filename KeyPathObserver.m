//
//  KeyPathObserver.m
//
//  Created by Olivier Halligon on 24/09/12.
//
//

#import "KeyPathObserver.h"
#import <objc/runtime.h>

//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KeyPathObserver Helper Class Interface


@interface KeyPathObserver : NSObject
+(KeyPathObserver*)observerForObject:(id)object;
-(void)onKeyPathValueChange:(NSString*)keyPath execute:(KeyPathObserverActionBlock)block;
-(void)removeAllObservedKeyPaths;
@property(nonatomic, retain) NSMutableDictionary* blocksMappings;
@property(nonatomic, assign) id targetObject;
@end


//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KeyPathObserver Category Implementation


@implementation NSObject (KeyPathObserver)

-(void)onKeyPathValueChange:(NSString*)keyPath execute:(KeyPathObserverActionBlock)block
{
    [[KeyPathObserver observerForObject:self] onKeyPathValueChange:keyPath execute:block];
}

-(NSArray*)observedKeyPaths
{
    return [[KeyPathObserver observerForObject:self].blocksMappings allKeys];
}

-(void)removeAllObservedKeyPaths
{
    [[KeyPathObserver observerForObject:self] removeAllObservedKeyPaths];
}


@end



//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KeyPathObserver Helper Class Implementation


@implementation KeyPathObserver
@synthesize blocksMappings = _blocksMappings;
@synthesize targetObject = _targetObject;

static char kKeyPathObserverContext;

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

-(void)removeAllObservedKeyPaths
{
    NSEnumerator* reverseEnum = [self.blocksMappings.allKeys reverseObjectEnumerator];
    for(NSString* keyPath in reverseEnum)
    {
        [self.targetObject removeObserver:self forKeyPath:keyPath context:&kKeyPathObserverContext];
    }
    [_blocksMappings removeAllObjects];
}

-(void)dealloc
{
    // Remove observers
    [self removeAllObservedKeyPaths];
    [_blocksMappings release];
    [super dealloc];
}

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