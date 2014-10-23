//	NavibarView.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NavibarView : NSView {
}

@property (strong, nonatomic) NSColor* backgroundPattern;

-(id) initWithFrame : (NSRect)frame;
-(void) drawRect:(NSRect)rect;

@end
