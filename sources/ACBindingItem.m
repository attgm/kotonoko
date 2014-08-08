//	ACBindingItem.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "ACBindingItem.h"


@implementation ACBindingItem

@synthesize selector = _selector;
@synthesize valueClass = _valueClass;
@synthesize observedController = _observedController;
@synthesize transformerName = _transformerName;
@synthesize observedKeyPath = _observedKeyPath;
@synthesize identifier = _identifier;


#pragma mark Initializing
//-- init
-(id) init
{
	self = [super init];
    if(self){
        self.observedController = self.observedKeyPath = self.transformerName = nil;
    }
    return self;
}


//-- initWithSelector:valueClass:
-(id) initWithSelector:(SEL) selector
			valueClass:(Class) valueClass
			identifier:(const void*) identifier
{
	self = [super init];
	if(self){
		self.observedController = self.observedKeyPath = self.transformerName = nil;
		_selector = selector;
		_valueClass = valueClass;
		_identifier = (void*) identifier;
	}
	return self;
}

//-- dealloc
-(void) dealloc
{
	self.observedController = nil;
    self.observedKeyPath = nil;
    self.transformerName = nil;
    [super dealloc];
}


//-- bingindItemFromSelector:valueClass:identifier:
//
+ (ACBindingItem*) bindingItemFromSelector : (SEL) selector
							  valueClass : (Class) valueClass
							   identifier: (const void*) identifier
{
	return [[[ACBindingItem alloc] initWithSelector:selector
									   valueClass:valueClass
									   identifier:identifier] autorelease];
}


//-- bingindItemFromACBindingItem
//
+(ACBindingItem*) bingindItemFromACBindingItem : (ACBindingItem*) item
{
	return [[[ACBindingItem alloc] initWithSelector:[item selector]
									   valueClass:[item valueClass]
									   identifier:[item identifier]] autorelease];
}


#pragma mark Interface
//-- infoForBinding
//
-(NSDictionary*) infoForBinding
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		_observedController,	NSObservedObjectKey,
		_observedKeyPath,	NSObservedKeyPathKey, 
		[NSDictionary dictionaryWithObject:_transformerName forKey:@"NSValueTransformerName"], NSOptionsKey,
		nil];
}

//-- unbind
// 
- (void) unbind
{
	[self setObservedController:nil];
	[self setObservedKeyPath:nil];
	[self setTransformerName:nil];
}

@end
