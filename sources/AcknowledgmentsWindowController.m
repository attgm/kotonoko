//	AcknowledgmentsWindowController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "AcknowledgmentsWindowController.h"


@implementation AcknowledgmentsWindowController
@synthesize acknowledgmentText = _acknowledgmentText;
@synthesize window = _window;

//-- init
//
-(id) init
{
    self = [super init];
    if(self != nil){
        self.window = nil;
    }
    return self;
}


//-- dealloc
//
-(void) dealloc
{
    self.window = nil;
    [super dealloc];
}


//-- showWindow
// create window and show window
- (void)showWindow
{
    if (self.window == nil) {
        if(![NSBundle loadNibNamed:@"AcknowledgmentsWindow" owner:self]){
			NSLog(@"Failed to load AcknowledgmentsWindow.xib");
			return;
		}

        [_acknowledgmentText readRTFDFromFile:[[NSBundle mainBundle] pathForResource:@"Acknowledgments" ofType:@"rtf"]];
        
	}
    [self.window center];
	[self.window makeKeyAndOrderFront:nil];
}


#pragma mark Window Delegate
- (void)windowWillClose:(NSNotification *)notification
{
    self.window = nil;
}

@end
