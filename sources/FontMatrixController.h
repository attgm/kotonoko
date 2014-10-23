//	FontMatrixController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FontMatrixController : NSArrayController {
	IBOutlet NSTextField* _textField;
	IBOutlet NSMatrix*	  _matrix;
}

-(IBAction) selectMatrix:(id) sender;

@end
