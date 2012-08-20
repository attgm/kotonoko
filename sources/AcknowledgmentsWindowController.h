//	AcknowledgmentsWindowController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AcknowledgmentsWindowController : NSObject<NSWindowDelegate>

@property (nonatomic, strong) IBOutlet NSWindow* window;
@property (nonatomic, assign) IBOutlet NSTextView* acknowledgmentText;


- (id)init;
- (void)dealloc;

- (void)showWindow;

@end
