//	ProgressPanel.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import "ProgressPanel.h"


@implementation ProgressPanel
@synthesize caption = _caption;
@synthesize animate = _animate;


-(instancetype) init
{
    self = [super initWithNibName:@"ProgressPanel" bundle:nil];
    return self;
}

#pragma mark Progress Sheet
//-- beginSheetForWindow:didEndSelector
// sheetwindowを表示させる
-(void) beginSheetForWindow : (NSWindow*) window
					 caption : (NSString*) caption
{
    // SheetWindowをnibファイルから生成する
    if (!self.view) {
        [self loadView];
    }
	
	NSRect frame = [[window contentView] frame];
	[self.view setFrame:frame];
	[window setContentView:self.view];
    
	[self setCaption:caption];
	
	[self setAnimate:YES];
}


//-- endSheet
// sheet windowを閉じる
-(void) endSheet
{
	[self.view removeFromSuperview];
	[self setAnimate:NO];
}

@end
