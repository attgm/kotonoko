//	ProgressPanel.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>


@interface ProgressPanel : NSObject {
	IBOutlet NSView* _panel;
	IBOutlet NSProgressIndicator* _progress;
	
	NSString* _caption;
	BOOL	_animate;
}

@property (nonatomic, retain) NSString* caption;
@property (nonatomic, assign) BOOL animate;

-(void) beginSheetForWindow : (NSWindow*) window
					caption : (NSString*) caption;
-(void) endSheet;

-(BOOL) animate;
-(void) setAnimate:(BOOL) animate;
-(NSString*) caption;
-(void) setCaption:(NSString*) caption;

@end
