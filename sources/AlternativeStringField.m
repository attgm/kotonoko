//	AlternativeStringField.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "AlternativeStringField.h"


@implementation AlternativeStringField

-(void) insertTab:(id) sender
{
	[super insertTab:sender];
	[_arrayController selectNext:self];
}

-(BOOL)			textView:(NSTextView *) textView
	 doCommandBySelector:(SEL) selector
{
	if(selector == @selector(insertTab:)){
		[_arrayController selectNext:self];
		return YES;
	}else if(selector == @selector(insertBacktab:)){
		[_arrayController selectPrevious:self];
		return YES;
	}
	return NO;
}
@end
