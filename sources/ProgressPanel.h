//	ProgressPanel.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>


@interface ProgressPanel : NSViewController {
	IBOutlet NSProgressIndicator* _progress;
	
	NSString* _caption;
	BOOL	_animate;
}

@property (nonatomic, strong) NSString* caption;
@property (nonatomic, assign) BOOL animate;

-(instancetype) init;
-(void) beginSheetForWindow : (NSWindow*) window
					caption : (NSString*) caption;
-(void) endSheet;

-(BOOL) animate;
-(void) setAnimate:(BOOL) animate;
-(NSString*) caption;
-(void) setCaption:(NSString*) caption;

@end
