//	ACMenuItem.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "ACMenuItem.h"
#import "ACBindingItem.h"

const NSString*	kMenuTitleBindingIdentifier = @"title";
const NSString* kMenuStateBindingIdentifier = @"state";
const NSString* kMenuKeyEquivalentIdentifier = @"keyEquivalent";

@implementation ACMenuItem

//-- init
//
-(id) init
{
	self = [super init];
	return self;
}


//-- dealloc
//
- (void)dealloc
{
	[self unbindAll];
	[_bindingItems release];
	[super dealloc];
}


#pragma mark Bindings

//-- bindingItems
// bindingItemを返す
-(NSDictionary*) bindingItems
{
	if(!_bindingItems){
		_bindingItems = [[NSDictionary alloc] initWithObjectsAndKeys:
			[ACBindingItem bindingItemFromSelector:@selector(observeTitle:)
										valueClass:[NSString class]
										identifier:kMenuTitleBindingIdentifier]
			, kMenuTitleBindingIdentifier,
			[ACBindingItem bindingItemFromSelector:@selector(observeState:)
										valueClass:[NSNumber class]
										identifier:kMenuStateBindingIdentifier]
			, kMenuStateBindingIdentifier,
			[ACBindingItem bindingItemFromSelector:@selector(observeKeyEquivalent:)
										valueClass:[NSString class]
										identifier:kMenuKeyEquivalentIdentifier]
			, kMenuKeyEquivalentIdentifier,
			nil];
	}
	return _bindingItems;
}


//-- valueClassForBinding:
//
-(Class) valueClassForBinding:(NSString *)binding {
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		return [item valueClass];
	}else{
		return [super valueClassForBinding:binding];
	}
}



//-- bind:toObject:withKeyPath:options:
//
- (void)		bind : (NSString *) binding
			toObject : (id) observableObject
		 withKeyPath : (NSString *) keyPath
			 options : (NSDictionary *) options
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		[item setObservedController:observableObject];
		[item setObservedKeyPath:keyPath];
		[item setTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:[item identifier]];
		[self performSelector:[item selector] withObject:item];
	}else{
		[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
	}
}    



//-- observeValueForKeyPath:ofObject:change:context:
//
- (void) observeValueForKeyPath : (NSString *) keyPath
					   ofObject : (id) object
						 change : (NSDictionary *) change
						context : (void *) context
{
	ACBindingItem* item = [[self bindingItems] objectForKey:context];
	if(item){
		[self performSelector:[item selector] withObject:item];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


//-- infoForBinding
//
- (NSDictionary*) infoForBinding : (NSString *) binding
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		return [item infoForBinding];
	}else{
		return [super infoForBinding:binding];
	}
}


//-- unbind
// 
- (void) unbind : (NSString *) binding
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}else{
		[super unbind:binding];
	}
}


//-- unbindAll
// 全てのobserverからselfを除く
-(void) unbindAll
{
	NSEnumerator* e = [[self bindingItems] objectEnumerator];
	ACBindingItem* item;
	while(item = [e nextObject]){
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}
}

#pragma mark Observers

//-- observeTitile 
// メニュータイトルの設定
-(void) observeTitle:(ACBindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		[self setTitle:value];
	}else{
		[self setTitle:@""];
	}
}


//-- observeState
// メニュー状態の設定
-(void) observeState:(ACBindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		[self setState:[value intValue]];
	}else{
		[self setState:NSOffState];
	}
}



//-- observeKeyEquivalent
// 
-(void) observeKeyEquivalent:(ACBindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		[self setKeyEquivalent:value];
		[self setKeyEquivalentModifierMask:NSCommandKeyMask];
	}else{
		[self setKeyEquivalent:@""];
	}
}
@end
