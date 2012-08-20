//	ContentsController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "ELDefines.h"
#import "SwipeView.h"

@class EBookController;
@class WindowController;
@class NavibarView;
@class WebView;
@class WebFrame;
@class QTMovieView;
@class QTMovie;
@class FontTableElement;
@class SwipeView;
@class ContentsHistory;

@interface WebViewAnimation : NSAnimation {
    WebView* _webview;
    CGFloat _endScale;
    CGFloat _startScale;
}
-(id)initWithWebView:(WebView*)webview duration:(NSTimeInterval)duration animationCurve:(NSAnimationCurve)animationCurve;
-(void)setScale:(CGFloat) scale;
-(void)setCurrentProgress:(NSAnimationProgress)progress;
@end;

@interface ContentsController : NSObject <SwipeViewDelegate> {
	IBOutlet WindowController* _windowController;
	
	IBOutlet SwipeView*			_contentsView;
	
	IBOutlet NSTextField*		_searchField;
		
	IBOutlet NSView*			_moviePanel;
	IBOutlet QTMovieView*		_qtView;
	
	IBOutlet NavibarView*		_charactorCodeView;
	IBOutlet NSTextField*		_charactorCodeString;
	
	IBOutlet WebView*			_webview;
	IBOutlet NSView*			_webContentsView;
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
}


-(id) init;
-(void) awakeFromNib;
-(void) dealloc;
-(void) finalize;

-(IBAction) backHistory:(id) sender;
-(IBAction) forwardHistory:(id) sender;
-(IBAction) closeCharactorCodePane:(id) sender;
-(IBAction) changeCharactorCode:(id) sender;
-(IBAction) searchInContent:(id)sender;


@property(readonly) ContentsHistory* history;

-(void) searchInTextContent;
-(void) searchInWebContent;

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



-(void) playWave:(NSURL*) reference;
-(void) playMovie:(NSURL*) reference;
-(void) showMoviePanel:(QTMovie*) movie;
-(void) closeMoviePanel;

-(void) showCharactorCode:(EBLocation) location;
-(void) showCharactorCodePane;
-(void) closeCharactorCodePane;
-(void) changeCharactorCode;
-(void) setWebContents:(NSURL*)url;

-(void) setShowGaijiCode:(BOOL)shown;
-(BOOL) showGaijiCode;

-(NSInteger) isOvercrollingContents;

- (void) addWebFramesWithParent:(WebFrame*) webFrame inArray:(NSMutableArray*) array;
-(NSArray*) webFrames:(WebView*) webview;
-(EBLocation) locationFromURL:(NSURL*) url;

-(void) setMenu:(NSURL*) url;


-(void) setNextKeyView:(NSView*) view;
-(NSView*) firstKeyView;

-(void) showErrorPage:(NSError*)error forFrame:(WebFrame*)frame;
-(NSString*) createErrorHtml:(NSError*) error;

-(void) contentBoundsDidChange:(NSNotification*) notify;
-(BOOL) hasContents:(NSInteger) detaction;

-(BOOL) contentsConinuity;
-(void) stopAppendTimer;
@end
