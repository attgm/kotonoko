//	FontMatrixController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "FontMatrixController.h"


@implementation FontMatrixController

//-- selectMatrix
// matrixが選択された時の処理
-(IBAction) selectMatrix:(id) sender
{
	if (![sender isKindOfClass:[NSMatrix class]]) return;
	if([sender selectedColumn] < 0 || [sender selectedRow] < 0){
		[self setSelectionIndex:-1];
	}else{
		NSInteger index = [sender selectedRow]*[sender numberOfColumns]+[sender selectedColumn];
		[self setSelectionIndex:index];
	}
	[[_textField window] makeFirstResponder:_textField];
}


//-- selectNext
// 次の文字を選択する
-(IBAction) selectNext:(id) sender
{
	NSUInteger index = [self selectionIndex];
	index++;
	if(index < [[self arrangedObjects] count]){
		[self setSelectionIndex:index];
		NSUInteger row = index / [_matrix numberOfColumns];
		NSUInteger column = index % [_matrix numberOfColumns];
	
		[_matrix selectCellAtRow:row column:column];
		[[_textField window] makeFirstResponder:_textField];
	}
}

//-- selectPrevious
// 前の文字を選択する
-(IBAction) selectPrevious:(id) sender
{
	NSUInteger index = [self selectionIndex];
	if(index > 0){
		[self setSelectionIndex:--index];
		NSUInteger row = index / [_matrix numberOfColumns];
		NSUInteger column = index % [_matrix numberOfColumns];
		
		[_matrix selectCellAtRow:row column:column];
		[[_textField window] makeFirstResponder:_textField];
	}
}


@end

