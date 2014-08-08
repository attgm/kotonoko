//	ACMenuItem.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class ACBindingItem;

@interface ACMenuItem : NSMenuItem {
	NSDictionary* _bindingItems;
}

-(id) init;
-(void) dealloc;

-(NSDictionary*) bindingItems;

-(Class) valueClassForBinding:(NSString *)binding;
-(void) bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *) options;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(NSDictionary*) infoForBinding:(NSString *) binding;
-(void) unbind:(NSString *) binding;
-(void) unbindAll;

-(void) observeTitle:(ACBindingItem*) item;
-(void) observeState:(ACBindingItem*) item;
-(void) observeKeyEquivalent:(ACBindingItem*) item;

@end
