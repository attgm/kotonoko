//	FontWell.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FontWell : NSButton <NSWindowDelegate>
{
	NSFont* _fontwellValue;
	
	id _observedControllerForValue;
	NSString* _observedKeyPathForValue;
	NSString* _valueTransformerName;
}

- (void)activate;
- (void)deactivate;
- (void) updateFontValue:(NSFont*) font;


-(void) syncValueToController;

-(void) setObservedControllerForValue:(id) controller;
-(void) setObservedKeyPathForValue:(NSString*) keypath;
-(void) setValueTransformerName:(NSString*) name;

@end
