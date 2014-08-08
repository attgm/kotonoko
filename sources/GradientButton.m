//	GradientButton.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "GradientButton.h"


@implementation GradientButton

+(Class) cellClass {
	return [GradientButtonCell class];
}

@end


#pragma mark -

@implementation GradientButtonCell

//-- drawBezelWithFrame
// 背景を描く
-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view
{
	BOOL highlighted = ([self isHighlighted] && (([self highlightsBy] & NSChangeGrayCellMask) == NSChangeGrayCellMask))
	|| ([self state] == NSOnState && (([self showsStateBy] & NSChangeGrayCellMask) == NSChangeGrayCellMask));
	BOOL enable = [self isEnabled];
	
	[NSGraphicsContext saveGraphicsState];
	
	CGFloat startWhite = enable ? (highlighted ? .65 : .99) : .93;
	CGFloat endWhite = enable ? (highlighted ? .62 : .95) : .95;
	CGFloat baseWhite = enable ? (highlighted ? .59 : .9) : .92;
	
	NSRect bounds = frame;
	bounds = NSMakeRect(bounds.origin.x+1, bounds.origin.y, bounds.size.width-2, bounds.size.height-1);
	
	CGFloat halfHeight = ceil(bounds.size.height/2);
	NSRect highlight = NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, halfHeight);
	NSColor* startColor = [NSColor colorWithDeviceWhite:startWhite alpha:1.0];
	NSColor* endColor = [NSColor colorWithDeviceWhite:endWhite alpha:1.0];
	NSGradient *backgroundGradient = [[[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor] autorelease];
	[backgroundGradient drawInRect:highlight angle:90];

	NSRect baseRect = NSMakeRect(bounds.origin.x, bounds.origin.y + halfHeight, bounds.size.width, bounds.size.height - halfHeight);
	[[NSColor colorWithDeviceWhite:baseWhite alpha:1.0] set];
	NSRectFill(baseRect);
	
	[[NSColor colorWithDeviceWhite:(highlighted ? .5 : 1.0) alpha:.5] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x, bounds.origin.y)
							  toPoint:NSMakePoint(bounds.origin.x, bounds.origin.y+bounds.size.height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x+bounds.size.width, bounds.origin.y)
							  toPoint:NSMakePoint(bounds.origin.x+bounds.size.width, bounds.origin.y+bounds.size.height)];

	
	//-- draw border
	bounds = frame;
	[[NSColor colorWithDeviceWhite:.75 alpha:1.0] set];
	NSBezierPath* border = [NSBezierPath bezierPath];
	[border setLineWidth:2.0];
	[border moveToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y)];
	[border lineToPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + bounds.size.height)];
	[border lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
	[border lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y)];
	[border stroke];
    
	[NSGraphicsContext restoreGraphicsState];	
}


@end