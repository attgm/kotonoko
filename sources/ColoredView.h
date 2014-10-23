//	ColoredView.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ColoredView : NSView {
	NSGradient* _backgroundGradient;
}

-(void) awakeFromNib;
-(void) drawRect:(NSRect)rect;

@end
