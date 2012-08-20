//	ACBindingItem.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@interface ACBindingItem : NSObject {
	SEL		_selector;
	Class	_valueClass;
	
	id	_observedController;
	NSString*	_observedKeyPath;
	NSString*	_transformerName;
	void*	_identifier;
}

+(ACBindingItem*) bindingItemFromSelector : (SEL) selector
							 valueClass : (Class) valueClass
							  identifier: (const void*) identifier;
+(ACBindingItem*) bingindItemFromACBindingItem : (ACBindingItem*) item;

-(id) init;
-(id) initWithSelector : (SEL) selector
			valueClass : (Class) valueClass
			 identifier: (const void*) identifier;
-(void) dealloc;

-(Class) valueClass;
-(SEL) selector;

-(void*) identifier;
-(id) observedController;
-(void) setObservedController:(id) controller;
-(NSString*) observedKeyPath;
-(void) setObservedKeyPath:(NSString*) keyPath;
-(NSString*) transformerName;
-(void) setTransformerName:(NSString*) transformerName;
-(NSDictionary*) infoForBinding;
-(void) unbind;

@end
