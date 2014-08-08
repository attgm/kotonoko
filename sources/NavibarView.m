//	NavibarView.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "NavibarView.h"


@implementation NavibarView

#pragma mark Initialize
//-- initWithFrame
// frameを用いて初期化する
- (id) initWithFrame : (NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

#pragma mark Draw
//-- drawRect
// 背景を描く
- (void)drawRect:(NSRect)rect
{
    if(self.backgroundPattern != nil){
        [self.backgroundPattern set];
        NSRectFill(self.bounds);
    }else{
        NSRect bounds = self.bounds;
        
        [[NSColor colorWithWhite:1.0f alpha:1.0f] set];
        NSRectFill(bounds);
        
        [[NSColor colorWithWhite:0.5f alpha:1.0] set];
        NSBezierPath* line = [[[NSBezierPath alloc] init] autorelease];
        [line moveToPoint:NSMakePoint(bounds.origin.x,
                                      bounds.origin.y)];
        [line lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width,
                                      bounds.origin.y)];
        [line setLineWidth: 1.0f];
        [line stroke];
    }
}

@end
