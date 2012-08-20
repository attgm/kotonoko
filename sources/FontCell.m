//	FontCell.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "FontCell.h"
#import "FontTableElement.h"

@implementation FontCell

//-- drawBezelWithFrame
// 背景を描く
-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view
{
	if([self state] == NSOffState){
		[[NSColor whiteColor] set];
	}else{
		[[NSColor selectedTextBackgroundColor] set];
	}
	NSRectFill(frame);
}


//-- drawInteriorWithFrame
// 文字を表示する
-(void) drawInteriorWithFrame:(NSRect)frame inView:(NSView*)view
{
	[NSGraphicsContext saveGraphicsState];
	NSRect innerRect = NSInsetRect(frame, 1.5, 1.5);
	
	NSImage* image = [self fontImage];
	NSSize imageSize = [image size]; 
	NSPoint imageOrigin = NSMakePoint(ceil((innerRect.size.width - imageSize.width) / 2 + innerRect.origin.x),  
									  innerRect.origin.y + 4.0 + imageSize.height);
	//[image drawAtPoint:imageOrigin fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	[image compositeToPoint:imageOrigin operation:NSCompositeSourceOver];
	
	NSFont* font = [self font];
	float fontHeight = [font ascender] - [font descender] + 3.0;
	NSRect fontRect = NSMakeRect(innerRect.origin.x, imageOrigin.y + 4.0, innerRect.size.width, fontHeight);
	
	NSMutableParagraphStyle *parapraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[parapraphStyle setAlignment:[self alignment]];
	[parapraphStyle setLineBreakMode:[self lineBreakMode]];
	NSColor* fontColor = [[self representedObject] useAlternativeString] ? [NSColor blackColor] : [NSColor grayColor];
	NSDictionary* stringAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  [self font], NSFontAttributeName,
									  fontColor, NSForegroundColorAttributeName,
									  parapraphStyle, NSParagraphStyleAttributeName, nil];
	[[self title] drawInRect:fontRect withAttributes:stringAttributes];
	[NSGraphicsContext restoreGraphicsState];	
}



//-- title
// タイトル文字列を返す
-(NSString*) title
{
	return [[self representedObject] alternativeString];
}


//-- fontImage
// フォントの画像を返す
-(NSImage*) fontImage
{
	return [[self representedObject] imageRepresentation];
}



@end
