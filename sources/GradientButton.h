//	GradientButton.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GradientButton : NSButton {

}

+(Class) cellClass;
@end


@interface GradientButtonCell : NSButtonCell {
}

-(void) drawBezelWithFrame:(NSRect)frame inView:(NSView*)view;

@end;
