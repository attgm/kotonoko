//	ACMenuBinder.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import "ACMenuBinder.h"
#import "ACBindingItem.h"
#import "ACMenuItem.h"
#import "DictionaryBinder.h"

const void* kMenusBindingIdentifier = (void*)@"menus";

@implementation ACMenuBinder

//-- init
-(id) init
{
	self = [super init];
    if(self){
        _menuitems = 0;
	}
    return self;
}


//-- dealloc
//
- (void)dealloc
{
	[[_bindingItem observedController] removeObserver:self forKeyPath:[_bindingItem observedKeyPath]];
	[_bindingItem release];
	[super dealloc];
}


//-- finalize
// 後片付け
-(void) finalize
{
	[[_bindingItem observedController] removeObserver:self forKeyPath:[_bindingItem observedKeyPath]];
	[super finalize];
}


#pragma mark Bindings
//-- bindingItem
// bindingを管理するクラスを返す
-(ACBindingItem*) bindingItem
{
	if(!_bindingItem){
		_bindingItem = [[ACBindingItem alloc] initWithSelector:@selector(observeMenus:)
												  valueClass:[NSArray class]
												  identifier:kMenusBindingIdentifier];
	}
	return _bindingItem;
}


//-- valueClassForBinding:
//
- (Class) valueClassForBinding:(NSString *)binding {
	
	if([binding isEqualToString:(NSString*)kMenusBindingIdentifier]){
		return [[self bindingItem] valueClass];
	}else{
		return [super valueClassForBinding:binding];
	}
}



//-- bind:toObject:withKeyPath:options:
//
- (void)		bind:(NSString *) binding
			toObject:(id) observableObject
		 withKeyPath:(NSString *) keyPath
			 options:(NSDictionary *) options
{
	if([binding isEqualToString:(NSString*)kMenusBindingIdentifier]){
		ACBindingItem* item = [self bindingItem];
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
	if(context == kMenusBindingIdentifier){
		ACBindingItem* item = [self bindingItem];
		[self performSelector:[item selector] withObject:item];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


//-- infoForBinding
//
- (NSDictionary*) infoForBinding : (NSString *) binding
{
	if(binding == kMenusBindingIdentifier){
		ACBindingItem* item = [self bindingItem];
		return [item infoForBinding];
	}else{
		return [super infoForBinding:binding];
	}
}



//-- unbind
// 
- (void) unbind : (NSString *) binding
{
	if(binding == kMenusBindingIdentifier){
		[self removeAllMenus];
		ACBindingItem* item = [self bindingItem];
		
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}else{
		[super unbind:binding];
	}
}

#pragma mark Bindings selector
//-- removeAllMenus
// メニューをすべて削除
-(void) removeAllMenus
{
	if(_menu){
		int i;
		for(i=0; i<_menuitems; i++){
			[_menu removeItemAtIndex:([_menu numberOfItems] - 1)];
		}
		_menuitems = 0;
	}
}


//-- adjustMenus
// 
-(void) observeMenus:(ACBindingItem*) item;
{
	NSArray* array = [[item observedController] valueForKey:[item observedKeyPath]];
	[self removeAllMenus];
	
	if(array && [array isKindOfClass:[NSArray class]]){
		NSEnumerator* e = [array objectEnumerator];
		id it;
		while(it = [e nextObject]){
			ACMenuItem* mi = [[[ACMenuItem alloc] init] autorelease];
			[mi bind:@"title" toObject:it withKeyPath:@"title" options:nil];
			[mi bind:@"keyEquivalent" toObject:it withKeyPath:@"keyEquivalent" options:nil];
			[mi setTag:[it binderId]];
			[mi setAction:@selector(handleMenuSelection:)];
			[mi setTarget:nil]; // send to first responder
			[_menu addItem:mi];
			_menuitems++;
		}
	}
}



@end
