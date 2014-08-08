//	PreferenceWindowController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PreferenceModal;
@class DictionaryManager;

@interface PreferenceWindowController : NSWindowController <NSToolbarDelegate>
{
	IBOutlet NSWindow* _preferenceWindow;
    IBOutlet NSView*	_panelBase;
	IBOutlet NSView*	_dictionaryPanel;
	IBOutlet NSView*	_booksetPanel;
	IBOutlet NSView*	_networkPanel;
	IBOutlet NSView*	_tagPanel;
	IBOutlet NSView*	_fontPanel;
	IBOutlet NSView*	_viewPanel;
	IBOutlet NSView*	_etcPanel;
	IBOutlet NSTreeController*	_treeController;
	IBOutlet NSArrayController* _quickTagController;
	
	PreferenceModal* _preferenceModal;
	NSMutableDictionary* _toolbarItems;
	NSDictionary* _panelViews;
	NSView*	_displayedPanel;
	
	NSMutableArray* _dictionaryList;
}

@property (assign, nonatomic) Boolean initialized;


- (IBAction) selectFolder : (id) sender;
- (IBAction) deleteFolder : (id) sender;
- (id) init;
- (void) dealloc;
- (void) windowWillClose : (NSNotification *) aNote;
- (void) showPanel : (id) sender;


+ (PreferenceWindowController*) sharedPrefenceWindowController;

-(void) createToolbar;
-(IBAction) switchPrefPanel:(id) sender;
-(void) switchPrefPanelById:(NSString*) identifier
					animate:(BOOL) animate;

//-(void) createDictionaryArray;
//-(void) appendDictionaryItem:(NSString*) path;
-(void) addDictionary:(NSString*) path;
-(void) addAppendix:(NSString*) path;

-(DictionaryManager*) dictionaries;

#pragma mark deletage : NSToolbar
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*) toolbar;
- (NSArray*) toolbarSelectableItemIdentifiers:(NSToolbar*) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*) toolbar;
- (NSToolbarItem *)     toolbar : (NSToolbar *) toolbar
          itemForItemIdentifier : (NSString *) itemIdentifier
      willBeInsertedIntoToolbar : (BOOL) flag;

@end