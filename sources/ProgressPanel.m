//	ProgressPanel.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import "ProgressPanel.h"


@implementation ProgressPanel
@synthesize caption = _caption;
@synthesize animate = _animate;


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

@end
