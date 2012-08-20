//	ACBindingItem.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "ACBindingItem.h"


@implementation ACBindingItem

#pragma mark Initializing
//-- init
-(id) init
{
	self = [super init];
    if(self){
        _observedController = _observedKeyPath = _transformerName = nil;
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
		_observedController = _observedKeyPath = _transformerName = nil;
		_selector = selector;
		_valueClass = valueClass;
		_identifier = (void*) identifier;
	}
	return self;
}

//-- dealloc
-(void) dealloc
{
	[_observedController release];
	[_observedKeyPath release];
	[_transformerName release];
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
//-- selector
//
-(SEL) selector
{
	return _selector;
}

//-- valueClass
//
-(Class) valueClass
{
	return _valueClass;
}


//-- identifier
//
-(void*) identifier
{
	return _identifier;
}


//-- observedController
//
-(id) observedController
{
	return _observedController;
}


//-- setObservedController
//
-(void) setObservedController:(id) controller
{
	[_observedController release];
	_observedController = [controller retain];
}


//-- observedKeyPath
//
-(NSString*) observedKeyPath
{
	return _observedKeyPath;
}



//-- observedKeyPath
//
-(void) setObservedKeyPath:(NSString*) keyPath
{
	[_observedKeyPath release];
	_observedKeyPath = [keyPath copyWithZone:[self zone]];
}


//-- transformerName
//
-(NSString*) transformerName
{
	return _transformerName;
}


//-- setTransformerName
//
-(void) setTransformerName:(NSString*) transformerName
{
	[_transformerName release];
	_transformerName = [transformerName copyWithZone:[self zone]];
}


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
