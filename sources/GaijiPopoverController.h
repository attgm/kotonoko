//
//  GaijiPopoverController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface GaijiPopoverController : NSViewController


@property (weak) IBOutlet NSTextField* alternativeString;
@property (weak) IBOutlet NSPopover*    popover;

-(void) closePopover;
-(IBAction)closePopover:(id)sender;
-(void) showPopoverRelativeToRect:(NSRect)rect ofView:(NSView*)view;

@end
