//	VerboseComboBox.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import "VerboseComboBox.h"


@implementation VerboseComboBox

//-- textView:observeKeyDownEvent:
// keydown eventを受けた時に呼び出される. イベントをそのままdelegateにスルーする.
-(void)			textView:(NSTextView*)textview
	 observeKeyDownEvent:(NSEvent*)event
{
	id delegate = [self delegate];
	if(delegate && [delegate respondsToSelector:@selector(textView:observeKeyDownEvent:)]){
		[delegate textView:textview observeKeyDownEvent:event];
	}
}


@end
