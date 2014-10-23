//	ColoredView.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "ColoredView.h"


@implementation ColoredView

//-- dealloc
// 後片付け



//-- awakeFromNib
// グラデーションを取得する
-(void) awakeFromNib
{
	
	NSColor* startColor = [NSColor colorWithCalibratedRed:.467 green:.588 blue:.71 alpha:1.0];
	NSColor* endColor = [NSColor colorWithCalibratedRed:.85 green:.87 blue:.90 alpha:1.0];	
	_backgroundGradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
}


//-- drawRect
// 
-(void) drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	
	//bounds.size.height -= 1;
	[_backgroundGradient drawInRect:bounds angle:90.0];
	//[[NSColor colorWithDeviceRed:0.85 green:0.87 blue:0.90 alpha:1.0 ] set];
	// NSRectFill(bounds);
	[[NSColor grayColor] set];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + bounds.size.height)
							  toPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height)];
	
}

@end
