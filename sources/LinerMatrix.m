//	LinerMatrix.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "LinerMatrix.h"
#import "ACBindingItem.h"
#import "PreferenceModal.h"
#import "BGButtonCell.h"

const NSString* kMatrixValueBindingIdentifier = @"value";
const NSString* kMatrixSelectionBindingIdentifier = @"selectedIndex";

@implementation LinerMatrix
+(Class) cellClass
{
	return [NSButtonCell class];
}

#pragma mark Initialize
//-- initWithFrame
// 初期化
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_matrixCells = [[NSMutableArray alloc] init];
		_pressedIndex = -1;
	}
    return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[self unbindAll];
	[_bindingItems release];
	[_matrixCells release];
	[super dealloc];
}


//-- finalize
// 後片付け
-(void) finalize
{
	[self unbindAll];
	[super finalize];
}


#pragma mark User Interface
//-- drawRect
// cellの表示
-(void) drawRect:(NSRect)rect {
	NSRect frame = [self frame];
	
	NSUInteger num = [_matrixCells count];
	if(num > 0){
		int width = frame.size.width / num;
	
		NSRect cellSize;
		cellSize.size.height = (frame.size.height + 2);
		cellSize.size.width = frame.size.width - (width * (num - 1));
		cellSize.origin = NSMakePoint(frame.size.width - cellSize.size.width, 0.0);
		
		NSEnumerator* e = [_matrixCells reverseObjectEnumerator];
		id it;
		while(it = [e nextObject]){
			[it setHighlighted:([it tag] == _pressedIndex)];
			[it setState:([it tag] == _selectedIndex ? NSOnState : NSOffState)];
			[it drawWithFrame:cellSize inView:self];
			cellSize.size.width = width;
			cellSize.origin.x -= width;
		}
	}else{
		[[NSColor windowBackgroundColor] set];
		NSRectFill(rect);
	}
}


//-- appendCell
// 新規にcellを作成する
-(NSButtonCell*) appendCell
{
	BGButtonCell* cell = [[[BGButtonCell alloc] initTextCell:@""] autorelease];
	[cell setBezeled:NO];
	//[cell setBezelStyle:NSShadowlessSquareBezelStyle];
	
	[cell setBezelStyle:NSSmallSquareBezelStyle];
	[cell setButtonType:NSPushOnPushOffButton];
	[cell setBaseWritingDirection:NSWritingDirectionNatural];
	[cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[cell setImagePosition:NSNoImage];
	[cell setEnabled:YES];
	[cell bind:@"font" toObject:[PreferenceModal sharedPreference] withKeyPath:kQuickTabFont
	   options:[NSDictionary dictionaryWithObject:@"FontNameToFontTransformer" forKey:@"NSValueTransformerName"]];
	//[cell setFont:[PreferenceModal fontForKey:kQuickTabFont]];
	[_matrixCells addObject:cell];
	
	return cell;
}



#pragma mark Mouse Event

//-- mouseDown
// マウスが押された時の処理
-(void) mouseDown:(NSEvent *) event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	_pressedIndex = [self cellIndexAtPoint:point];
	//[[self cellAtIndex:_pressedIndex] setHighlighted:YES];
	[self setNeedsDisplay:YES];
}


//-- mouseUp
// マウスが離された時の処理
-(void) mouseUp:(NSEvent *) event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	int index = [self cellIndexAtPoint:point];
	if(index == _pressedIndex){
		[self setSelectedIndex:_pressedIndex];
	}
	_pressedIndex = -1;
	[self setNeedsDisplay:YES];
}


//-- cellIndexAtPoint
// 座標とcell indexの対応づけを行う
-(int) cellIndexAtPoint:(NSPoint) point
{
	NSRect frame = [self frame];
	
	if (point.y < 0 || point.y > frame.size.height) {
		return -1;
	}
	
	NSUInteger num = [_matrixCells count];
	if(num > 0){
		int width = frame.size.width / num;
		int offset = frame.size.width - (width * num);
		int index = (point.x - offset) / width;
		return index > 0 ? index : 0;
	}
	return -1;
}


//-- cellAtIndex
// indexからNSCellを返す
-(NSCell*) cellAtIndex:(int) index
{
	if(index >= 0 && index < [_matrixCells count]){
		return [_matrixCells objectAtIndex:index];
	}
	return nil;
}


//-- setSelectedIndex
// 選択しているindexを設定する
-(void) setSelectedIndex:(int) index
{
	if(index >=0 && index < [_matrixCells count]){
		_selectedIndex = index;
		ACBindingItem* item = [[self bindingItems] objectForKey:kMatrixSelectionBindingIdentifier];
		[[item observedController] setValue:[NSNumber numberWithInt:_selectedIndex]
								 forKeyPath:[item observedKeyPath]];
		[self performClick:nil];
	}
}


#pragma mark Bindings
//-- bindingItems
// bindingItemを返す
-(NSDictionary*) bindingItems
{
	if(!_bindingItems){
		_bindingItems = [[NSDictionary alloc] initWithObjectsAndKeys:
			[ACBindingItem bindingItemFromSelector:@selector(observeValue:)
										valueClass:[NSArray class]
										identifier:kMatrixValueBindingIdentifier]
			, kMatrixValueBindingIdentifier,
			[ACBindingItem bindingItemFromSelector:@selector(observeSelectedIndex:)
										valueClass:[NSNumber class]
										identifier:kMatrixSelectionBindingIdentifier]
			, kMatrixSelectionBindingIdentifier,
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


#pragma mark Observer
//-- observeValue 
// メニュータイトルの設定
-(void) observeValue:(ACBindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		[self setContentsArray:value];
		//[self sendActionOn:NSLeftMouseDownMask];
		if([_matrixCells count] > 0 && _selectedIndex > 0){
			[self performClick:nil];
		}
		//[[self target] performSelector:[self action] withObject:self];
	}else{
		[_matrixCells removeAllObjects];
		[self setNeedsDisplay:YES];
	}
}


//-- observeSelectedIndex
// 選択されたindexの変更
-(void) observeSelectedIndex:(ACBindingItem*) item
{
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		int index = [value intValue];
		if(index >=0 && index < [_matrixCells count]){
			_selectedIndex = index;
		}else{
			_selectedIndex = -1;
		}
	}
	[self setNeedsDisplay:YES];
}


//-- setContentsArray
// ButtonCellの中身を変更する
-(void) setContentsArray:(NSArray*) array
{
	int i;
	for(i=0; i<[array count]; i++){
		NSButtonCell* cell = (i < [_matrixCells count]) ? [_matrixCells objectAtIndex:i] : [self appendCell];
		id it = [array objectAtIndex:i];
		[cell bind:@"title" toObject:it withKeyPath:@"tagName" options:nil];
		[cell setTag:i];
	}
	while([array count] < [_matrixCells count]){
		[_matrixCells removeLastObject];
	}
	[self setNeedsDisplay:YES];
}

@end
