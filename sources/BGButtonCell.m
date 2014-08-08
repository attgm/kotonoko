//	BGButtonCell.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "BGButtonCell.h"


@implementation BGButtonCell

//-- drawBezelWithFrame
// 背景を描く
-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view
{
/*
    NSColor* borderLineColor = [NSColor colorWithDeviceWhite:.63 alpha:1.0];

    NSGradient* centerGradient;
    if([self isHighlighted]){
		centerGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:.89 alpha:1.0]
                                                        endingColor:[NSColor colorWithDeviceWhite:.74 alpha:1.0]]
                          autorelease];
	}else if([self state] == NSOnState){
		centerGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:.78 green:.85 blue:.95 alpha:1.0]
                                                        endingColor:[NSColor colorWithDeviceRed:.62 green:.69 blue:.80 alpha:1.0]]
                          autorelease];
    }else{
    	centerGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:.83 alpha:1.0]
                                                        endingColor:[NSColor colorWithDeviceWhite:.98 alpha:1.0]]
                          autorelease];
	}

    NSColor* highlightLineColor = [NSColor colorWithDeviceWhite:1.0 alpha:.50];
    
	NSRect  bounds = frame;
    
    [NSGraphicsContext saveGraphicsState];
    // fill gradient
    [centerGradient drawInRect:bounds angle:90];
    // draw border
    [borderLineColor set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x + 0.5f, bounds.origin.y + 0.5f)
							  toPoint:NSMakePoint(bounds.origin.x + 0.5f, bounds.origin.y + bounds.size.height - 0.5f)];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x + 0.5f, bounds.origin.y + 0.5f)
							  toPoint:NSMakePoint(bounds.origin.x + bounds.size.width + 0.5f, bounds.origin.y + 0.5f)];
    // draw highlight
    [highlightLineColor set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x+bounds.size.width - 0.5f, bounds.origin.y + 1.5f)
							  toPoint:NSMakePoint(bounds.origin.x+bounds.size.width - 0.5f, bounds.origin.y + bounds.size.height - 0.5f)];
    
    [NSGraphicsContext restoreGraphicsState];	
 */
    
    NSColor* borderLineColor = [NSColor colorWithDeviceWhite:.63 alpha:1.0];
    
    NSColor* backgroundColor;
    if([self isHighlighted]){
        backgroundColor = [NSColor colorWithDeviceWhite:.75f alpha:1.0f];
    }else if([self state] == NSOnState){
        backgroundColor = [NSColor colorWithDeviceRed:.62 green:.69 blue:.80 alpha:1.0];
    }else{
        backgroundColor = [NSColor colorWithDeviceWhite:.85f alpha:1.0f];
    }
    
    NSRect  bounds = frame;
    
    [backgroundColor set];
    NSRectFill(bounds);
    // draw border
    [borderLineColor set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x + 0.5f, bounds.origin.y + 0.5f)
                              toPoint:NSMakePoint(bounds.origin.x + 0.5f, bounds.origin.y + bounds.size.height - 0.5f)];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(bounds.origin.x + 0.5f, bounds.origin.y + 0.5f)
                              toPoint:NSMakePoint(bounds.origin.x + bounds.size.width + 0.5f, bounds.origin.y + 0.5f)];
}


//-- drawInteriorWithFrame
// 文字を表示する
-(void) drawInteriorWithFrame:(NSRect)frame inView:(NSView*)view
{
	[NSGraphicsContext saveGraphicsState];
	NSRect innerRect = NSInsetRect(frame, 1.5, 1.5);
	
	NSFont* font = [self font];
	CGFloat gap = (innerRect.size.height - ([font ascender] - [font descender] + 3.0));
	
	if(gap > 0.0){
		innerRect = NSInsetRect(innerRect, 0, gap/2);
	}
	NSMutableParagraphStyle *parapraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[parapraphStyle setAlignment:[self alignment]];
	[parapraphStyle setLineBreakMode:[self lineBreakMode]];
	NSDictionary* stringAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName,
		parapraphStyle, NSParagraphStyleAttributeName, nil];
	[[self title] drawInRect:innerRect withAttributes:stringAttributes];
	[NSGraphicsContext restoreGraphicsState];	
}

@end
