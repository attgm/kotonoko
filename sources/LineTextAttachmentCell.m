//	LineTextAttachmentCell.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import "LineTextAttachmentCell.h"


@implementation LineTextAttachmentCell

//-- init
// 初期化
-(id) init
{
	self = [super init];
	if(self){
		_width = 100.0f;
		_attachment = nil;
	}
	return self;
}



//-- drawWithFrame:inView:
//
-(void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView
{
	[[NSColor grayColor] set];
	NSBezierPath* line = [[[NSBezierPath alloc] init] autorelease];
	[line moveToPoint:NSMakePoint(cellFrame.origin.x + 4,
								  cellFrame.origin.y + cellFrame.size.height/2)];
	[line lineToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width,
								cellFrame.origin.y + cellFrame.size.height/2)];
	[line setLineWidth: 1.0f];
	[line stroke];
}


//-- drawWithFrame:inView:characterIndex:
-(void) drawWithFrame:(NSRect)cellFrame
			   inView:(NSView *)controlView
	   characterIndex:(NSUInteger)charIndex
{
	[self drawWithFrame:cellFrame inView:controlView];
}


//-- drawWithFrame:inView:characterIndex:
-(void) drawWithFrame:(NSRect)cellFrame
			   inView:(NSView *)controlView
	   characterIndex:(NSUInteger)charIndex
		layoutManager:(NSLayoutManager *)layoutManager
{
	[self drawWithFrame:cellFrame inView:controlView];
}


//-- highlight:withFrame:inView
-(void) highlight:(BOOL)flag
		withFrame:(NSRect)cellFrame
		   inView:(NSView *)aView
{
	
}


//-- cellBaselineOffset
//
-(NSPoint) cellBaselineOffset
{
	return NSMakePoint(0,0);
}

//-- cellSize
- (NSSize) cellSize
{
	return NSMakeSize(_width, 3);
}



//--- cellFrameForTextContainer:proposedLineFragment:glyphPosition:characterIndex:
- (NSRect) cellFrameForTextContainer:(NSTextContainer *)textContainer
				proposedLineFragment:(NSRect)lineFrag
					   glyphPosition:(NSPoint)position
					  characterIndex:(NSUInteger)charIndex
{
	_width = lineFrag.size.width - 16;
	return NSMakeRect(0,0, _width, 3);
}



//-- trackMouse:inRect:ofView:atCharacterIndex:untilMouseUp:
- (BOOL) trackMouse:(NSEvent *)theEvent
			inRect:(NSRect)cellFrame
			ofView:(NSView *)aTextView
  atCharacterIndex:(NSUInteger)charIndex
	  untilMouseUp:(BOOL)flag
{
	return NO;
}


//-- trackMouse:inRect:ofView:untilMouseUp:
- (BOOL) trackMouse:(NSEvent *)theEvent
			 inRect:(NSRect)cellFrame
			 ofView:(NSView *)aTextView
	   untilMouseUp:(BOOL)flag
{
	return NO;
}


//-- wantsToTrackMouse
-(BOOL) wantsToTrackMouse
{
	return NO;
}

//-- wantsToTrackMouseForEvent:inRect:ofView:atCharacterIndex:
-(BOOL) wantsToTrackMouseForEvent:(NSEvent *)theEvent
								   inRect:(NSRect)cellFrame
								   ofView:(NSView *)controlView
						 atCharacterIndex:(NSUInteger)charIndex
{
	return NO;
}



//-- attachment
- (NSTextAttachment *) attachment
{
	return _attachment;
}

-(void) setAttachment:(NSTextAttachment*) attachment
{
	if(attachment != _attachment){
		[_attachment autorelease];
		_attachment = [attachment retain];
	}
}


@end
