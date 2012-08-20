//	VerboseFieldEditer.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "VerboseFieldEditer.h"


@implementation VerboseFieldEditer

//-- keydown
// キーが押された時のイベント
-(void) keyDown:(NSEvent*) event
{
	[super keyDown:event];
	
	id delegate = [self delegate];
	if(delegate && [delegate respondsToSelector:@selector(textView:observeKeyDownEvent:)]){
		[delegate textView:self observeKeyDownEvent:event];
	}
}


@end
