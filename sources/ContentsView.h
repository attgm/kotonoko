//	ContentsView.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "ELDefines.h"

@class ContentsController;

@interface ContentsView : NSTextView
{
	IBOutlet ContentsController* _contentsController;
}



-(void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context;
-(void) observeLinkAttributes;

@end
