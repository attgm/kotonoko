//	AlternativeStringField.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AlternativeStringField : NSTextField {
	IBOutlet NSArrayController* _arrayController;
}

-(void) insertTab:(id) sender;
-(BOOL)        textView:(NSTextView *) textView
    doCommandBySelector:(SEL) selector;
@end
