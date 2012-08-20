//	ProgressPanel.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import "ProgressPanel.h"


@implementation ProgressPanel

#pragma mark Progress Sheet
//-- beginSheetForWindow:didEndSelector
// sheetwindowを表示させる
-(void) beginSheetForWindow : (NSWindow*) window
					 caption : (NSString*) caption
{
    // SheetWindowをnibファイルから生成する
    if (!_panel) {
		if (![NSBundle loadNibNamed:@"ProgressPanel" owner:self])  {
			NSLog(@"Failed to load ProgressPanel.nib");
			NSBeep();
            return;
		}
    }
	
	NSRect frame = [[window contentView] frame];
	[_panel setFrame:frame];
	[window setContentView:_panel];
	[self setCaption:caption];
	
	[self setAnimate:YES];
}


//-- endSheet
// sheet windowを閉じる
-(void) endSheet
{
	[_panel removeFromSuperview];
	[self setAnimate:NO];
}

#pragma mark Bindings

//-- animate
-(BOOL) animate
{ 
	return _animate;
}


//-- setAnimate
-(void) setAnimate:(BOOL) animate
{
	[self willChangeValueForKey:@"animate"];
	_animate = animate;
	[self didChangeValueForKey:@"animate"];
}

//-- caption
-(NSString*) caption
{
	return _caption;
}


//-- setCaption
-(void) setCaption:(NSString*) caption
{
	[self willChangeValueForKey:@"caption"];
	[_caption release];
	_caption = [caption copyWithZone:[self zone]];
    [self didChangeValueForKey:@"caption"];
}

@end
