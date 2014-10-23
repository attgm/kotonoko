//	AcknowledgmentsWindowController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AcknowledgmentsWindowController : NSWindowController <NSWindowDelegate>
{
}

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView* acknowledgmentText;


- (id)init;
- (void)dealloc;

- (void)showWindow;

@end
