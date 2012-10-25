//
//  NVButtonCell.m
//  ebooks
//
//  Created by Atsushi on 2012/09/26.
//
//

#import "NVButtonCell.h"

@implementation NVButtonCell


//-- drawBezelWithFrame
// 背景を描く
-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view
{
    if(((self.highlightsBy & NSPushInCellMask) && self.state == NSOnState) || self.isHighlighted == YES){
        //NSColor *beginColor = [NSColor colorWithDeviceRed:0.37f green:0.42f blue:0.52f alpha:1.0f];
        //NSColor *endColor = [NSColor colorWithDeviceRed:0.57f green:0.62f blue:0.72f alpha:1.0f];
        
        NSColor *beginColor = [NSColor colorWithDeviceRed:0.27f green:0.31f blue:0.39f alpha:1.0f];
        NSColor *endColor = [NSColor colorWithDeviceRed:0.41f green:0.45f blue:0.53f alpha:1.0f];
        NSGradient *gradient =
            [[[NSGradient alloc] initWithStartingColor:beginColor endingColor:endColor] autorelease];
        [gradient drawInRect:frame angle:90];
        
        [[NSColor colorWithDeviceWhite:0.2f alpha:0.8f] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x, frame.origin.y)
                                  toPoint:NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y)
                                  toPoint:NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)];

    }
}


@end
