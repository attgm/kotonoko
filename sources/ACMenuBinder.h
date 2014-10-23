//	ACMenuBinder.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class ACBindingItem;

@interface ACMenuBinder : NSObject {
	IBOutlet NSMenu* _menu;
	unsigned int _menuitems;	
	ACBindingItem* _bindingItem;
}

-(id) init;
- (void)dealloc;

-(ACBindingItem*) bindingItem;
-(Class) valueClassForBinding:(NSString *)binding;
-(void) bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *) options;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(NSDictionary*) infoForBinding:(NSString *) binding;
-(void) unbind:(NSString *) binding;

-(void) removeAllMenus;
-(void) observeMenus:(ACBindingItem*) item;

@end
