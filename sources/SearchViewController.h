//	SearchViewController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HistoryDataSource;
@class EBookController;
@class WindowController;

@interface SearchViewController : NSViewController
{
    IBOutlet HistoryDataSource*	_history;
    IBOutlet NSComboBox*		_inputTextField;
    IBOutlet NSPopUpButton*		_methodPopup;
    
    WindowController*	_windowController;	
	unsigned int _resultsMax;
}

- (IBAction)switchSearchMethod:(id)sender;
- (IBAction)searchWordAll:(id)sender;

- (id) initWithWindowController:(WindowController*)inWindowController;
- (NSView*) firstController;

- (NSTextField*) inputField;
- (void) moveFocus;

-(void) research;

- (void) selectSearchMethodWithTag:(NSInteger) inIndex;
- (void) setSearchMethods:(NSArray*) methods;
- (void) clearSearchWord;
- (void) setEnabled:(BOOL) enable;

-(void) setNextKeyView:(NSView*) view;
@end
