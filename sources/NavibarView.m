//	NavibarView.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "NavibarView.h"


@implementation NavibarView

#pragma mark Initialize
//-- initWithFrame
// frameを用いて初期化する
- (id) initWithFrame : (NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
		_backgroundPattern = nil;
	}
    return self;
}


//-- setBackgroundColor
// 背景に描画するイメージの名前を設定する
-(void) setBackgroundColor:(NSColor*) color
{
	if(_backgroundPattern != nil){ [_backgroundPattern release]; };
	_backgroundPattern = [color retain];
}


#pragma mark Draw
//-- drawRect
// 背景を描く
- (void)drawRect:(NSRect)rect
{
    if(_backgroundPattern != nil){
        [_backgroundPattern set];
        NSRectFill([self bounds]);
    }else{
        NSColor *beginColor = [NSColor colorWithDeviceRed:0.57f green:0.62f blue:0.72f alpha:1.0f];
        NSColor *endColor = [NSColor colorWithDeviceRed:0.37f green:0.42f blue:0.52f alpha:1.0f];
        NSGradient *gradient =
            [[[NSGradient alloc] initWithStartingColor:beginColor endingColor:endColor] autorelease];
        [gradient drawInRect:[self bounds] angle:270];
    }
}

@end
