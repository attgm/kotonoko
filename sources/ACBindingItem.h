//	ACBindingItem.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
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

@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) Class valueClass;

@property (nonatomic, strong) id observedController;
@property (nonatomic, copy) NSString* transformerName;
@property (nonatomic, copy) NSString* observedKeyPath;
@property (nonatomic, readonly) void* identifier;

+(ACBindingItem*) bindingItemFromSelector : (SEL) selector
							 valueClass : (Class) valueClass
							  identifier: (const void*) identifier;
+(ACBindingItem*) bingindItemFromACBindingItem : (ACBindingItem*) item;

-(id) init;
-(id) initWithSelector : (SEL) selector
			valueClass : (Class) valueClass
			 identifier: (const void*) identifier;

-(NSDictionary*) infoForBinding;
-(void) unbind;

@end
