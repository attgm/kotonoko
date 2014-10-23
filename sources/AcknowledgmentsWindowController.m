//	AcknowledgmentsWindowController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "AcknowledgmentsWindowController.h"


@implementation AcknowledgmentsWindowController
@synthesize acknowledgmentText = _acknowledgmentText;


//-- init
//
-(id) init
{
    self = [super initWithWindowNibName:@"AcknowledgmentsWindow" owner:self];
    
    return self;
}


//-- dealloc
//
-(void) dealloc
{
    self.window = nil;
}


//-- showWindow
// create window and show window
- (void)showWindow
{
    if (self.window != nil) {
        [self.acknowledgmentText readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Acknowledgments" ofType:@"rtf"]];
	}
    [self.window center];
	[self.window makeKeyAndOrderFront:nil];
}


@end
