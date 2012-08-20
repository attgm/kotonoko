//	MultiSearchViewController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EBookController;
@class WindowController;

@interface MultiSearchViewController : NSObject
{
	IBOutlet NSMatrix*		_entryMatrix;
	IBOutlet NSPopUpButton*	_methodPopup;
    IBOutlet NSView*		_searchView;
    IBOutlet NSTokenField*	_tokenTextField;
	IBOutlet NSView*		_searchEntries;
    IBOutlet NSView *		_searchFieldView;
	IBOutlet NSScrollView *_searchEntriesView;
	IBOutlet NSButton*		_disclosureButton;
	
	WindowController*		_windowController;
	NSMutableArray*			_entriesArray;
	NSView*					_firstKeyView;
}

- (IBAction)switchSearchMethod:(id)sender;
- (IBAction)searchWordAll:(id)sender;
- (IBAction) discloseSearchEntry:(id) sender;

- (id) initWithWindowController:(WindowController*) windowController;
- (void) createSearchView;

//- interface
- (NSView*) view;
- (NSView*) firstController;

- (void) moveFocus;
- (void) selectSearchMethodWithTag:(NSInteger) inIndex;
- (void) setSearchMethods:(NSArray*) searchMethods;
//--
- (NSArray*) entries;


-(void) setSearchEntriesAtIndex:(NSInteger) index;
-(NSView*) searchEntriesView;

-(void) adjustEntriesView;
-(void) didEntriesChanged;

-(void) setContentsViewToSearchEntriesView;
- (void) moveFocus;
@end
