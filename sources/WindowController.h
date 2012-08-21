//	WindowController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>
@class EBookController;
@class ContentsView;
@class SearchViewController;
@class MultiSearchViewController;
@class PreferenceModal;
@class ContentsController;

@class ProgressPanel;
@class DictionaryBinder;


@class LinerMatrix;
@class VerboseFieldEditer;


@interface WindowController :  NSObject <NSAnimationDelegate>
{
    // MainWindow.nib
    IBOutlet LinerMatrix*		_binderMatrix;
	IBOutlet NSTableView*		_headingTable;
    IBOutlet NSClipView*		_searchClip;
    IBOutlet NSView*			_contentsClip;
    IBOutlet NSSplitView*		_splitView;
    IBOutlet NSWindow*			_window;
	IBOutlet NSView*			_contentView;

	IBOutlet NSArrayController* _binderController;
	IBOutlet NSArrayController* _headingController;
	
	
	IBOutlet ContentsController* _contentsController;
	
	//
	ProgressPanel*				_progressPanel;
	
    EBookController*			_ebookController;
    
    NSView*						_searchView;
    NSTimer*					_searchViewAnimeTimer;

	ESearchMethod				_searchMethod;
	id							_currentSearchViewController;
	SearchViewController*		_searchViewController;
    MultiSearchViewController*  _multiSearchViewController;
	
	
	VerboseFieldEditer*			_fieldEditer;
	DictionaryBinder*			_currentDictionaryBinder;
	NSArray*					_resultsArray;
}

- (IBAction) privDictionary : (id)sender;
- (IBAction) nextDictionary : (id)sender;
- (IBAction) changeDictionary: (id)sender;
- (IBAction) find:(id) sender;

- (void) selectHeading:(NSNotification*)notification;
-(void) selectBinder:(DictionaryBinder*) binder;

- (id) initWithController:(EBookController*) inController;
- (void) createMainWindow;
- (void) createWindowContent;
- (void) syncWindowStyle;

- (void) setTitle:(NSString*) inTitle;
- (void) showFront;
- (NSWindow*) window;

- (void) setContentsView:(NSView*) contentsView;
- (NSView*) currentContentsView;
- (void) setContentsViewToDictionaryContents;

- (void) setSearchView:(NSView*)inSearchView;
- (void) setSearchView:(NSView*)inSearchView withAnime:(BOOL)isAnime;
- (void) searchViewAnime : (id) inUserInfo;

- (void) moveFocusToHeading;
- (BOOL) selectFirstHeading;
- (void) setInputText:(NSString*) inString;

- (void) runPageLayout;
- (void) print; 

- (void) changeSearchMethod : (ESearchMethod) inMethod;
//- (void) changeMultiSearchMethod : (int) inIndex;

- (void) becomeMainWindow : (NSNotification *) inNotification;
- (void) moveFocusToSearchView;
- (ESearchMethod) searchMethod;
-(BOOL) adjustSearchMethod;


-(void) showProgressSheet:(NSString*) inCaption;
-(void) hideProgressSheet;
-(ProgressPanel*) progressPanel;

-(void) selectQuickTab:(id) binder;

-(id) fieldEditer;
-(id) windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id) obj;
-(void) updateHeadingFont;
-(NSDictionary*) headingParamator;

-(DictionaryBinder*) currentDictionaryBinder;
-(void) setCurrentDictionaryBinder:(DictionaryBinder*) binder;
- (void) searchWord:(NSString*)inWord max:(int)inMaxNumber;
- (void) searchEntries:(NSArray*) inWord max:(int) inMaxNumber;


-(NSArray*) resultsArray;
-(void) setResultsArray:(NSArray*) results;

-(void) setNextKeyView:(NSView*) view;


@end
