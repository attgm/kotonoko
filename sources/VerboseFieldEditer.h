//	VerboseFieldEditer.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@interface VerboseFieldEditer : NSTextView {
	
}

@end


@interface NSObject (VerboseFieldEditer)

-(void) textView:(NSTextView*)textview observeKeyDownEvent:(NSEvent*)event;

@end