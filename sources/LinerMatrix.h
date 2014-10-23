//	LinerMatrix.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ACBindingItem;

@interface LinerMatrix : NSControl {
	NSMutableArray* _matrixCells;
	NSDictionary* _bindingItems;
	int _pressedIndex;
	int _selectedIndex;
}

+(Class) cellClass;

-(NSButtonCell*) appendCell;
-(void) drawRect:(NSRect)rect;

-(void) mouseDown:(NSEvent *) event;
-(void) mouseUp:(NSEvent *) event;
-(int) cellIndexAtPoint:(NSPoint) point;
-(NSCell*) cellAtIndex:(int) index;
-(void) setSelectedIndex:(int) index;


-(NSDictionary*) bindingItems;

-(Class) valueClassForBinding:(NSString *)binding;
-(void) bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *) options;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(NSDictionary*) infoForBinding:(NSString *) binding;
-(void) unbind:(NSString *) binding;
-(void) unbindAll;


-(void) observeValue:(ACBindingItem*) item;
-(void) observeSelectedIndex:(ACBindingItem*) item;
-(void) setContentsArray:(NSArray*) array;
@end
