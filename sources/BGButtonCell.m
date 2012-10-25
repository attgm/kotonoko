//	BGButtonCell.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "BGButtonCell.h"


@implementation BGButtonCell

//-- drawBezelWithFrame
// 背景を描く
-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view
{
	NSImage* leftImage;
	NSImage* image;
	NSImage* rightImage;
	if([self isHighlighted]){
		leftImage = [NSImage imageNamed:@"tab_highlight_left"];
		rightImage = [NSImage imageNamed:@"tab_right"];
		image = [NSImage imageNamed:@"tab_highlight_center"];
	}else if([self state] == NSOnState){
		leftImage = [NSImage imageNamed:@"tab_on_left"];
		rightImage = [NSImage imageNamed:@"tab_right"];
		image = [NSImage imageNamed:@"tab_on_center"];
	}else{
		leftImage = [NSImage imageNamed:@"tab_off_left"];
		rightImage = [NSImage imageNamed:@"tab_right"];
		image = [NSImage imageNamed:@"tab_off_center"];
	}
	
	NSRect  bounds = frame;
    NSRect  srcRect, destRect;
	// 左側のハイライト
	srcRect.origin = NSZeroPoint;
    srcRect.size = [leftImage size];
	destRect.origin = NSMakePoint(bounds.origin.x,0);
    destRect.size = srcRect.size;
	[leftImage drawInRect:destRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0f];
	bounds.origin.x += srcRect.size.width;
	bounds.size.width -= srcRect.size.width;
	// 右側のシャドウ
	srcRect.origin = NSZeroPoint;
    srcRect.size = [rightImage size];
    destRect.origin = NSMakePoint(bounds.origin.x + bounds.size.width - srcRect.size.width, 0);
    destRect.size = srcRect.size;
	[rightImage drawInRect:destRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0f];
	bounds.size.width -= srcRect.size.width;
	// 真ん中
	srcRect.origin = NSZeroPoint;
    srcRect.size = [image size];
    destRect.origin.y = 0;
    destRect.size = srcRect.size;
	
	CGFloat x = bounds.origin.x;
    while (x < bounds.size.width + bounds.origin.x) {
        destRect.origin.x = x;
        [image drawInRect:destRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0f];
        x += srcRect.size.width;
    }	
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
