//	BGButtonCell.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BGButtonCell : NSButtonCell {

}

-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view;
-(void) drawInteriorWithFrame:(NSRect)frame inView:(NSView*)view;

@end
