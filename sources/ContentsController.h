//	ContentsController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "ELDefines.h"
#import "SwipeView.h"

@class EBookController;
@class WindowController;
@class NavibarView;
@class FontTableElement;
@class SwipeView;
@class ContentsHistory;
@class WebViewController;
@class PlayerViewController;
//@class GaijiViewController;
@class GaijiPopoverController;


@interface ContentsController : NSObject <SwipeViewDelegate, NSPopoverDelegate>{
	IBOutlet WindowController* _windowController;
	
	IBOutlet SwipeView*			_contentsView;
	
	IBOutlet NSTextField*		_searchField;
		
	IBOutlet NSView*			_moviePanel;
	
	IBOutlet NavibarView*		_charactorCodeView;
	IBOutlet NSTextField*		_charactorCodeString;
	
	IBOutlet NSProgressIndicator*	_progressIndicator;
	IBOutlet NSButton*			_forwardButton;
	IBOutlet NSButton*			_backButton;
	IBOutlet NSButton*			_largeButton;
	IBOutlet NSButton*			_smallButton;
	IBOutlet NSButton*			_showGaijiButton;
	IBOutlet NSButton*			_contentsConinuityButton;
	
	IBOutlet NSTextView*		_textView;
	IBOutlet NSScrollView*		_textContentsView;
	
	BOOL						_showGaijiCode;
	BOOL						_contentsConinuity;
    ContentsHistory*            _history;
    
	//unsigned int				_historyIndex;
	
	FontTableElement*			_currentCharactorElement;
	
	NSTimer*					_appendTimer;
	BOOL						_hasSerialContents;
	EBLocation					_serialLocation;
    BOOL						_hasBackwordContents;
	EBLocation					_backwordLocation;
    
    
    NSTextFinder*               _textFinder;
    
    GaijiPopoverController*     _gaijiPopoverController;
    
}


@property (strong, nonatomic) NSTextFinder* textFinder;
@property (strong, nonatomic) WebViewController* webviewController;

@property (strong, nonatomic) PlayerViewController* playerViewController;
@property (assign, nonatomic) BOOL isTextOrientationVertical;



-(id) init;
-(void) awakeFromNib;
-(void) dealloc;

-(IBAction) backHistory:(id) sender;
-(IBAction) forwardHistory:(id) sender;

-(IBAction) searchInContent:(id)sender;
-(IBAction) closeMoviePanel:(id)sender;

@property(readonly) ContentsHistory* history;

-(void) searchInTextContent;
//-(void) searchInWebContent;

-(void) moveFocusToContentsSearch;

-(NSTextView*) textView;


-(void) setEmptyContents;
-(void) setContentURL:(NSURL*)url appendHistory:(BOOL)history refleshCache:(BOOL)cache;
-(void) setEBookContents:(NSURL*) url;
-(void) setCopyright:(NSURL*) url;
-(void) adjustToolbar:(NSView*) view;

-(void) addLocationHistory:(NSURL*) location;
-(void) moveHistoryAt:(NSUInteger)index refleshCache:(BOOL)reflesh;
-(void) refleshCurrentDisplayCache;
-(void) refleshCurrentDisplayCache:(NSBitmapImageRep*) bitmap;
-(NSBitmapImageRep*) getHistoryDisplayCacheBy:(NSInteger) offset;
-(void) swipeBy:(NSInteger)offset;
-(void) switchDictionaryBy:(NSInteger) offset;
-(BOOL) canSwipeBy:(NSInteger)offset;

-(void) updateContentsFont:(NSNotification*) notification;

-(void) reloadContents;

-(void) refleshTextOrientation;


-(void) playWave:(NSURL*) reference;
-(void) playMovie:(NSURL*) reference;
-(void) closeMoviePanel;

-(void) showCharactorCode:(EBLocation) location inRect:(NSRect)rect;
-(void) showCharactorCodePaneInRect:(NSRect)rect;
-(void) closeCharactorCodePane;
-(void) changeCharactorCode;
-(void) setWebContents:(NSURL*)url;

-(void) setShowGaijiCode:(BOOL)shown;
-(BOOL) showGaijiCode;

-(NSInteger) isOvercrollingContents;
-(EBLocation) locationFromURL:(NSURL*) url;

-(void) setMenu:(NSURL*) url;


-(void) setNextKeyView:(NSView*) view;
-(NSView*) firstKeyView;

-(void) adjustTextViewSize;

-(void) contentBoundsDidChange:(NSNotification*) notify;
-(BOOL) hasContents:(NSInteger) detaction;

-(BOOL) contentsConinuity;
-(void) stopAppendTimer;
@end
