//	ColoredView.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ColoredView : NSView {
	NSGradient* _backgroundGradient;
}

-(void) dealloc;
-(void) awakeFromNib;
-(void) drawRect:(NSRect)rect;

@end
