//	ContentsController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <WebKit/WebKit.h>
#import <QTKit/QTkit.h>

#import "ContentsController.h"
#import "EBookController.h"
#import "DictionaryListItem.h"
#import "DictionaryManager.h"
#import "DictionaryBinderManager.h"
#import "DictionaryBinder.h"
#import "EBook.h"
#import "PreferenceModal.h"
#import "WindowController.h"
#import "NavibarView.h"

#import "EBStyleSheet.h"
#import "FontTableElement.h"
#import "NetDictionary.h"
#import "EBookUtilities.h"
#import "SwipeView.h"
#import "ContentsHistory.h"

NSString* const EBContentFontBindingsIdentifier = @"contentFont";
NSInteger const OVERSCROLL_MARGIN = 12;
NSInteger const DIRECTION_OVER_TOP = -1;
NSInteger const DIRECTION_OVER_BOTTOM = 1;


@interface WebHTMLView : NSView <WebDocumentView>
- (NSUInteger)markAllMatchesForText:(NSString *)string caseSensitive:(BOOL)caseFlag limit:(unsigned)limit;
- (void)unmarkAllTextMatches;
- (void)setMarkedTextMatchesAreHighlighted:(BOOL)newValue;
@end

@interface WebView (WebPendingPublic)
@property float pageSizeMultiplier;
-(IBAction)resetPageZoom:(id)sender;
@end


@implementation WebViewAnimation
//-- initWithDuration:animationCurve:
//
- (id)initWithWebView:(WebView*)webview
             duration:(NSTimeInterval)duration
       animationCurve:(NSAnimationCurve)animationCurve
{
    self = [super initWithDuration:duration animationCurve:animationCurve];
    if(self){
        _webview = webview;
    }
    return self;
}

//-- setStartScale
// setStartScale
-(void) setScale:(CGFloat) scale
{
    if(_webview != nil){
        _endScale = scale;
        if([_webview respondsToSelector:@selector(pageSizeMultiplier)]){
            _startScale = [_webview pageSizeMultiplier];
        }else{
            _startScale = 1.0f;
        }
    }
}

//-- setCurrentProgress:
// 
- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];
    
    if([_webview respondsToSelector:@selector(setPageSizeMultiplier:)]){
        CGFloat scale = progress * (_endScale - _startScale) + _startScale;
        [_webview setPageSizeMultiplier:scale];
    }
}
@end;


@implementation ContentsController
@synthesize history = _history;

//-- init
//
-(id) init
{
	self = [super init];
    if(self){
        _appendTimer = nil;
	
        [[PreferenceModal sharedPreference] addObserver:self
                                             forKeyPath:kContentsFont
                                                options:NSKeyValueObservingOptionNew												
                                                context:(void*)EBContentFontBindingsIdentifier];
        [[PreferenceModal sharedPreference] addObserver:self
                                             forKeyPath:kIndexColor
                                                options:NSKeyValueObservingOptionNew
                                                context:(void*)EBContentFontBindingsIdentifier];
        [[PreferenceModal sharedPreference] addObserver:self
                                             forKeyPath:kContentsColor
                                                options:NSKeyValueObservingOptionNew
                                                context:(void*)EBContentFontBindingsIdentifier];
        _contentsConinuity = [[PreferenceModal prefForKey:kContentsConinuity] boolValue];
	
        _history = [[[ContentsHistory alloc] init] retain];
    }
	return self;
}


//-- awakeFromNib
// 起動時の設定
-(void) awakeFromNib
{
	// Scrollerの動きをトレースする
	NSView* contentView = [_textContentsView contentView];
	[contentView setPostsBoundsChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(contentBoundsDidChange:)
												 name:NSViewBoundsDidChangeNotification
											   object:contentView];
    [_textContentsView setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"backgroundPattern"]]];
}


//-- dealloc
//
- (void)dealloc
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsFont];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kIndexColor];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsColor];
	
	[_appendTimer release];
	
	[super dealloc];
}


//-- finalize
//
-(void) finalize
{
    [[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsFont];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kIndexColor];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsColor];
	
    [super finalize];
}


#pragma mark Action
//-- backHistrory
// 履歴をさかのぼる
-(IBAction) backHistory:(id) sender
{
	if([_history canBackHistory]){
		[self moveHistoryAt:([_history historyIndex] - 1) refleshCache:YES];
	}
}


//-- forwardHistrory
// 履歴を先に進む
-(IBAction) forwardHistory:(id) sender
{
	if([_history canForwardHistory]){
		[self moveHistoryAt:([_history historyIndex] + 1) refleshCache:YES];
	}
}



//-- closeCharactorCodePane
// 外字paneを閉じる
-(IBAction) closeCharactorCodePane:(id) sender
{
	[self closeCharactorCodePane];
}


//-- changeCharactorCode
-(IBAction) changeCharactorCode:(id) sender
{
	[self changeCharactorCode];
}


#pragma mark Contents
//-- setContentView:
//  表示viewを指定する
-(void) setContentView:(NSView*) view
{
	if(_webview && [_webview isLoading]){
		[_webview stopLoading:self];
	}
	if([view superview] == nil){
		NSRect frame = [_contentsView frame];
		frame.origin.x = frame.origin.y = 0.0;
		[view setFrame:frame];
		[_contentsView setSubviews:[NSArray arrayWithObject:view]];
		[view setNextKeyView:_searchField];
		[_windowController setNextKeyView:view];
		
		[self adjustToolbar:view];
	}
}



//-- adjustToolbar
// content viewに合わせてtoolbarを切り替える
-(void) adjustToolbar:(NSView*) view
{
	[_largeButton setHidden:!(view == _webContentsView)];
	[_smallButton setHidden:!(view == _webContentsView)];
	[_showGaijiButton setHidden:!(view == _textContentsView)]; 
	[_contentsConinuityButton setHidden:!(view == _textContentsView)]; 
}


//-- setNextKeyView:
// tab chainの設定
-(void) setNextKeyView:(NSView*) view
{
	[_searchField setNextKeyView:view];
}


//-- firstKeyView
// tab chainの先頭のviewを返す
-(NSView*) firstKeyView
{
	return [[_contentsView subviews] objectAtIndex:0];
}


//-- textView
// TextViewを返す(印刷用)
-(NSTextView*) textView
{
	return _textView;
}


//-- setContentURL
// contentのURLを設定する.
-(void) setContentURL:(NSURL*) url
		appendHistory:(BOOL) history
         refleshCache:(BOOL) cache
{
	[_searchField setStringValue:@""];
	[self closeMoviePanel];
	_hasSerialContents = NO;
	[self stopAppendTimer];
	
	if(!url){ return; };
	
    if(cache == true){
        [self refleshCurrentDisplayCache];
    }
    
	if([[url scheme] isEqualToString:@"eb"]){
		[self setEBookContents:url];
	}else if([[url scheme] isEqualToString:@"copyright"]){
		[self setCopyright:url];
	}else if([[url scheme] isEqualToString:@"menu"]){
		[self setMenu:url];
	}else if([[url scheme] isEqualToString:@"web"]){
		[self setWebContents:url];
	}
    
    [_history addURL:url historyItem:history];
}	

//-- stopAppendTimer
// 追加タイマの停止
-(void) stopAppendTimer
{
	if(_appendTimer){
		[_appendTimer invalidate];
		[_appendTimer release];
		_appendTimer = nil;
	}
}

//-- contentsParamator
// 文章のパラメタ
-(NSDictionary*) contentsParamator
{
	NSFont* contentsFont = [PreferenceModal fontForKey:kContentsFont];
	NSFont* scriptFont = [NSFont fontWithName:[contentsFont fontName] size:([contentsFont pointSize]*0.75)];
	
	NSColor* contentsColor = [PreferenceModal colorForKey:kContentsColor];
	NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									contentsFont,							NSFontAttributeName,
									contentsColor,							NSForegroundColorAttributeName, nil];
	float gap = [contentsFont ascender] - [scriptFont ascender];
	NSDictionary* superscriptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										   scriptFont,						NSFontAttributeName,
										   contentsColor,					NSForegroundColorAttributeName,
										   [NSNumber numberWithFloat:gap],	NSBaselineOffsetAttributeName, nil];
	gap = [scriptFont descender] - [contentsFont descender];
	NSDictionary* subscriptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										 scriptFont,						NSFontAttributeName,
										 contentsColor,						NSForegroundColorAttributeName,
										 [NSNumber numberWithFloat:gap],	NSBaselineOffsetAttributeName, nil];
	int imageHeight = ceil([contentsFont ascender] - [contentsFont descender]);
	NSDictionary* emphasisAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										contentsColor,									 NSForegroundColorAttributeName,
										contentsFont,									 NSFontAttributeName,
										[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName, nil];
	NSDictionary* keywordAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									   contentsFont,									 NSFontAttributeName,
									   [PreferenceModal colorForKey:kIndexColor],		 NSForegroundColorAttributeName, nil];
	NSDictionary* gaijiAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									 scriptFont,										NSFontAttributeName,
									 [NSNumber numberWithFloat:-2.0],					NSBaselineOffsetAttributeName,
									 [NSNumber numberWithInt:NSSingleUnderlineStyle],	NSUnderlineStyleAttributeName, nil];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			superscriptAttributes,							EBSuperScriptAttributes,
			subscriptAttributes,							EBSubScriptAttributes,
			keywordAttributes,								EBKeywordAttributes,
			gaijiAttributes,								EBGaijiAttributes,
			emphasisAttributes,								EBEmphasisAttributes,
			textAttributes,									EBTextAttributes,
			[NSNumber numberWithBool:_showGaijiCode],		EBShowGaijiCode,
			[NSNumber numberWithBool:_contentsConinuity],	EBContentsConinuity,
			[NSNumber numberWithInt:imageHeight],			EBFontImageHeight, 
			[PreferenceModal colorForKey:kLinkColor],		EBReferenceTextColor, nil];
}



//-- setEmptyContents:
// 空白に設定
-(void) setEmptyContents
{
	[self setContentView:_textContentsView];
	[_textView scrollRangeToVisible:NSMakeRange(0,0)];
	[[_textView textStorage] beginEditing];
	[[_textView textStorage] setAttributedString:
	 [[[NSAttributedString alloc] initWithString:@""] autorelease]];
	[[_textView textStorage] endEditing];
	[_textView sizeToFit];
}



//-- setEBookContents:
// 電子辞書コンテンツの設定
-(void) setEBookContents:(NSURL*) url
{
	[self setContentView:_textContentsView];
    EBLocation location = [self locationFromURL:url];
    _backwordLocation = location;
	EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:location.ebook];
	
	NSDictionary* paramator = [self contentsParamator];
	NSAttributedString* text = [eb contentAt:location paramator:paramator];
	
    _hasSerialContents = [eb hasSerialContents:&_serialLocation];
	_serialLocation.ebook = location.ebook;
    
    _hasBackwordContents = [eb hasBackwordContents:&_backwordLocation];
	
	[_textView scrollRangeToVisible:NSMakeRange(0,0)];
	[[_textView textStorage] beginEditing];
	[[_textView textStorage] setAttributedString:text];
	[[_textView textStorage] endEditing];
	[_textView sizeToFit];
	
    if([self contentsConinuity] && ([self isOvercrollingContents] == DIRECTION_OVER_BOTTOM)  && _hasSerialContents){
		[self stopAppendTimer];
		_appendTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5f
														 target:self
													   selector:@selector(timeoutOverScrollingTimer:)
													   userInfo:[NSNumber numberWithInt:1]
														repeats:NO] retain];
	}
}


//-- appendEBookContents:
// 電子辞書コンテンツを追加する
-(void) appendEBookContents:(int) direction
{
    if([self hasContents:direction] == false) return;
	
	[self setContentView:_textContentsView];
    EBLocation location = (direction == DIRECTION_OVER_TOP) ? _backwordLocation : _serialLocation;
	EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:location.ebook];
	
	NSAttributedString* text = [eb contentAt:location paramator:[self contentsParamator]];
	
    NSInteger originalHeight = [[_textContentsView documentView] frame].size.height;
    [[_textView textStorage] beginEditing];
    if(direction < 0){
        [[_textView textStorage] insertAttributedString:text atIndex:0];
    }else{
        [[_textView textStorage] appendAttributedString:text];
    }
	[[_textView textStorage] endEditing];
    [_textView sizeToFit];
	
    NSInteger offset = [[_textContentsView documentView] frame].size.height - originalHeight;
    if(offset > OVERSCROLL_MARGIN && direction == DIRECTION_OVER_TOP){
        NSClipView* clipView = [_textContentsView contentView];
        NSPoint origin = [clipView bounds].origin;
        origin.y += offset;
        [clipView setBoundsOrigin:origin];
        origin.y -= OVERSCROLL_MARGIN;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            [[clipView animator] setBoundsOrigin:origin];
        } completionHandler:^{}];
    }
    
    if(direction == DIRECTION_OVER_TOP){
        _backwordLocation = location;
        _hasBackwordContents = [eb hasBackwordContents:&_backwordLocation];
    }else{
        _hasSerialContents = [eb hasSerialContents:&_serialLocation];
        _serialLocation.ebook = location.ebook;
	
        if([self contentsConinuity] && ([self isOvercrollingContents] == DIRECTION_OVER_BOTTOM) && _hasSerialContents){
            _appendTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector(timeoutOverScrollingTimer:)
                                                           userInfo:[NSNumber numberWithInt:1]
                                                            repeats:NO] retain];
        }
    }
}


//-- isOvercrollingContents
// コンテンツがOverScrollingしているかどうかの判定. していない場合は0
-(NSInteger) isOvercrollingContents
{
    if ([[_textView textStorage] length] > [[PreferenceModal prefForKey:kContentsCharactersMax] intValue]) return NO;
    
    NSRect cv = [[_textContentsView contentView] bounds]; 
	NSRect df = [[_textContentsView documentView] frame];
	
	return (cv.origin.y - df.origin.y) < 0 ? DIRECTION_OVER_TOP
        : (df.size.height - (cv.origin.y + cv.size.height - df.origin.y)) <= 0 ? DIRECTION_OVER_BOTTOM : 0;
}


//-- setCopyright:
// 著作権情報の表示
-(void) setCopyright:(NSURL*) url
{
	[self setContentView:_textContentsView];
	NSArray* path = [[url path] pathComponents];
	NSAttributedString* text = nil;
	if([path count] == 2){
		unsigned binderId = [[path objectAtIndex:1] intValue];
		DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:binderId];
		if(binder){
			text = [binder copyrightWithParamator:[self contentsParamator]];
		}
	}

	if(!text){
		text = [[[NSAttributedString alloc] initWithString:@""] autorelease];
	}
	[_textView scrollRangeToVisible:NSMakeRange(0,0)];
	[[_textView textStorage] beginEditing];
	[[_textView textStorage] setAttributedString:text];
	[[_textView textStorage] endEditing];
	[_textView sizeToFit];
}


//-- setMenu:
// メニューの表示
-(void) setMenu:(NSURL*) url
{
	[self setContentView:_textContentsView];
	NSArray* path = [[url path] pathComponents];
	NSAttributedString* text = nil;
	if([path count] == 2){
		unsigned binderId = [[path objectAtIndex:1] intValue];
		DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:binderId];
		if(binder && [binder respondsToSelector:@selector(menuWithParamator:)]){
			text = [(SingleBinder*)binder menuWithParamator:[self contentsParamator]];
		}
	}
	
	if(!text){
		text = [[[NSAttributedString alloc] initWithString:@""] autorelease];
	}
	[_textView scrollRangeToVisible:NSMakeRange(0,0)];
	[[_textView textStorage] beginEditing];
	[[_textView textStorage] setAttributedString:text];
	[[_textView textStorage] endEditing];
	[_textView sizeToFit];
	[_windowController setResultsArray:[NSArray array]];
}


//-- setWebContents:
// Webコンテンツの表示
-(void) setWebContents:(NSURL*) url
{
	if(!_webContentsView){
		if (![NSBundle loadNibNamed:@"WebView" owner:self])  {
			NSLog(@"Failed to load WebView.nib");
			NSBeep();
            return;
		}
		[EBStyleSheet sharedStyleSheet];
		
		[_progressIndicator bind:@"value" toObject:_webview withKeyPath:@"estimatedProgress" options:nil];
		[_progressIndicator bind:@"hidden" toObject:_webview withKeyPath:@"isLoading" 
						 options:[NSDictionary dictionaryWithObject:@"NSNegateBoolean" forKey:@"NSValueTransformerName"]];
		[_largeButton setAction:@selector(makeTextLarger:)];
		[_largeButton setTarget:_webview];
		[_largeButton bind:@"enabled" toObject:_webview withKeyPath:@"canMakeTextLarger" options:nil];
		[_smallButton setAction:@selector(makeTextSmaller:)];
		[_smallButton setTarget:_webview];
		[_smallButton bind:@"enabled" toObject:_webview withKeyPath:@"canMakeTextSmaller" options:nil];
	}
	
	NSString* urlString = [url absoluteString];
	NSString* hostname = [url host];
	if(hostname && urlString){
		NSRange scheme = [urlString rangeOfString:hostname];
		NSString* path = [urlString substringFromIndex:(scheme.location + scheme.length + 1)]; // 最初の1文字(/)を削除

		[self setContentView:_webContentsView];
        [_webview resetPageZoom:nil];
		[[_webview mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
	}
}


//-- reloadContents
// reload the current contents
-(void) reloadContents
{
    [self setContentURL:[_history currentURL] appendHistory:NO refleshCache:NO];
}


#pragma mark History

//-- addLocationHistory
// location履歴に追加する
-(void) addLocationHistory:(NSURL*) url
{
//	NSBitmapImageRep* bitmap = [_contentsView getBitmapImageRepForCachingDisplay];
	[_history addHistoryItem:[ContentsHistoryItem historyItemWithUrl:url bitmap:nil]];
}


//-- moveHistoryAt
// 履歴の移動
-(void) moveHistoryAt:(NSUInteger)index refleshCache:(BOOL)reflesh
{
    NSURL* url = [_history moveHistoryAt:index];
	if(url){
		[self setContentURL:url appendHistory:NO refleshCache:YES];
	}
}

//-- refleshCurrentDisplayCache
// reflesh display cache as current display
-(void) refleshCurrentDisplayCache
{
    NSBitmapImageRep* bitmap = [_contentsView getBitmapImageRepForCachingDisplay];
    [self refleshCurrentDisplayCache:bitmap];
}


//-- refleshCurrentDisplayCacheByBitmapImageRep
// reflesh display cache by bitmapImageRep
-(void) refleshCurrentDisplayCache:(NSBitmapImageRep*) bitmap
{
    [_history setCurrentDisplayCache:bitmap];
}

//-- getgetHistoryDisplayCacheBy
// return display cache bitmap
-(NSBitmapImageRep*) getHistoryDisplayCacheBy:(NSInteger) offset
{
    return [_history getCurrentDisplayCache:offset];
}

//-- swipeToBackword
// swipe to backword contents
-(void) swipeBy:(NSInteger) offset
{
    if(offset == 0){
        [self reloadContents];
    }else if([self canSwipeBy:offset]){
        [self moveHistoryAt:([_history historyIndex] + offset) refleshCache:NO];
	}
}


//-- canSwipeBy
// can swipe
-(BOOL) canSwipeBy:(NSInteger) offset
{
    return ((offset < 0 && [_history canBackHistory]) || (offset > 0 && [_history canForwardHistory]));
}


//-- switchDictionartBy:
// switch dictionary
-(void) switchDictionaryBy:(NSInteger) offset
{
    if(offset < 0){
        [_windowController privDictionary:nil];
    }else{
        [_windowController nextDictionary:nil];
    }
}


//-- updateContentsFont
// Fontの変更
-(void) updateContentsFont:(NSNotification*) notification
{
	[self reloadContents];
}




#pragma mark Search

//-- moveFocusToContentsSearch
// フォーカスを検索窓に移す
-(void) moveFocusToContentsSearch
{
	[[_searchField window] makeFirstResponder:_searchField];
}


//-- webFrames
// webframeに含まれるframeをすべて返す
- (void) addWebFramesWithParent:(WebFrame*)webFrame inArray:(NSMutableArray*)array
{
    [array addObject:webFrame];
    
    NSEnumerator*   e = [[webFrame childFrames] objectEnumerator];
    WebFrame*       frame;
	while (frame = [e nextObject]) {
        [self addWebFramesWithParent:frame inArray:array];
    }
}



//-- webFrames
// webviewに含まれるframeをすべて返す
-(NSArray*) webFrames:(WebView*) webview
{
	NSMutableArray* array = [NSMutableArray array];
	
	[self addWebFramesWithParent:[webview mainFrame] inArray:array];
	return array;
}


//-- searchInContent
// 本文表示エリアの中を検索する
-(IBAction) searchInContent:(id)sender
{
	if([_textContentsView window] != nil){
		[self searchInTextContent];
	}
	if([_webContentsView window] != nil){
		[self searchInWebContent];
	}
}


-(void) searchInWebContent
{  
	//NSColor* color = [PreferenceModal colorForKey:kFindColor];
	NSString* searchString = [_searchField stringValue]; // 検索文字列の取得
	
	
 //[_webview searchFor:searchString direction:YES caseSensitive:NO wrap:YES];
	NSEnumerator* e = [[self webFrames:_webview] objectEnumerator];
	WebFrame* frame;
	while (frame = [e nextObject]) {
		id  documentView = [[frame frameView] documentView];
		if ([documentView respondsToSelector:@selector(unmarkAllTextMatches)]){
			[documentView unmarkAllTextMatches];
		}
		if ([documentView respondsToSelector:@selector(setMarkedTextMatchesAreHighlighted:)]){
			[documentView setMarkedTextMatchesAreHighlighted:YES];
		}
		if ([documentView respondsToSelector:@selector(markAllMatchesForText:caseSensitive:limit:)]){
			[documentView markAllMatchesForText:searchString caseSensitive:NO limit:0];
		}
	}
}


//-- searchInTextContent
// text content内を検索する
-(void) searchInTextContent
{
	NSColor* color = [PreferenceModal colorForKey:kFindColor];
	NSString* searchString = [_searchField stringValue]; // 検索文字列の取得
	
 	NSRange indicatorRange = NSMakeRange(0, 0);
	
    [[_textView textStorage] beginEditing];// 編集開始
    // 検索用の素の文字列を取得
    NSString* contentString = [[_textView textStorage] string];
    unsigned int length = [contentString length];
    NSRange searchRange = NSMakeRange(0, [contentString length]);
	unsigned int rangeNum = 0;
    // 背景色を削除する
    [[_textView textStorage] removeAttribute:NSBackgroundColorAttributeName range:searchRange];
    // 検索ルーチン
    if(![searchString isEqualToString:@""]){
		NSRange range;
        do {
            range = [contentString rangeOfString:searchString
												 options:(NSCaseInsensitiveSearch | NSLiteralSearch)
												   range:searchRange];
            if(range.length > 0){
                [[_textView textStorage] addAttribute:NSBackgroundColorAttributeName
                                                value:color
                                                range:range];
                searchRange.location = NSMaxRange(range);
                searchRange.length = length - searchRange.location;
				
				if(rangeNum < 1){
					indicatorRange = range;
				}
				rangeNum++;
            }
        } while(range.length != 0);
    }
    // 編集終了
    [[_textView textStorage] endEditing];
	
	if(indicatorRange.length > 0){
		[_textView scrollRangeToVisible:indicatorRange];		
		[_textView showFindIndicatorForRange:indicatorRange];
	}
}


#pragma mark Multimedia
//-- playWave
// 音声の再生
-(void) playWave:(NSURL*) url
{
	NSArray* path = [[url path] pathComponents];
	if([path count] == 6){
		int ebookNumber = [[path objectAtIndex:1] intValue];
		EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:ebookNumber];
		NSData* data = [eb soundWithPath:[url path]];
    
		if (data != nil && [data length] > 0) {
			NSError* error;
			QTDataReference* reference = [QTDataReference dataReferenceWithReferenceToData:data
																					  name:@"kotonoko.wav"
																				  MIMEType:@"audio/wav"];
			QTMovie* movie = [QTMovie movieWithDataReference:reference error:&error];
			
			if(movie){
				[self showMoviePanel:movie];
			}else{
				NSLog(@"ERROR:%@", [error localizedDescription]);
			}
		}
	}
}


//-- playMovie
// 動画の再生
-(void) playMovie:(NSURL*) url
{
	NSArray* path = [[url path] pathComponents];
	if([path count] == 3){
		int ebookNumber = [[path objectAtIndex:1] intValue];
		EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:ebookNumber];;
		
		NSData* data = [eb movieByName:[path objectAtIndex:2]];
		QTDataReference* reference = [QTDataReference dataReferenceWithReferenceToData:data
																				  name:@"kotonoko.mpg"
																			  MIMEType:@"movie/mpeg"];
		
		NSError* error;
		QTMovie* movie = [QTMovie movieWithDataReference:reference error:&error];
		
		if(movie){
			[self showMoviePanel:movie];
		}else{
			NSLog(@"ERROR:%@", [error localizedDescription]);
		}
	}
}


//-- showMoviePanel
// movie用のパネルを表示する
-(void) showMoviePanel:(QTMovie*) movie
{
	if(!_moviePanel){
		if(![NSBundle loadNibNamed:@"MoviePanel" owner:self]){
			NSLog(@"Failed to load MoviePanel.nib");
			NSBeep();
		}
	}
	
	NSSize size = [[movie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	
	[_qtView setMovie:movie];
	NSRect qtRect = [_qtView frame];
	NSRect controlBound = [_qtView movieControllerBounds];
	if(size.width == 0) size.width = 240;
	size.height += controlBound.size.height;
	float movieHeight = size.height + 32;
	qtRect.size = size;
	 
	float currentHeight = 0;
	if([_moviePanel superview] == nil){
		[_contentsView addSubview:_moviePanel];
		currentHeight = 0;
	}else{
		currentHeight = ([_moviePanel frame]).size.height;
	}
	
	NSRect movieRect = [_moviePanel frame];
	NSRect contentsRect = [_textContentsView frame];
	
	movieRect.size.height = movieHeight;
	contentsRect.size.height -= (movieRect.size.height - currentHeight);
	movieRect.size.width = contentsRect.size.width;
	movieRect.origin.x = 0; movieRect.origin.y = contentsRect.size.height + contentsRect.origin.y;
	[_moviePanel setFrame:movieRect];
	[_textContentsView setFrame:contentsRect];
	
	qtRect.origin.x = round((movieRect.size.width - size.width) / 2);
	[_qtView setFrame:qtRect];
	
	[_moviePanel setNeedsDisplay:YES];
	if([PreferenceModal prefForKey:kPlaySoundAutomatically]){
		[_qtView play:self];
	}
}


//-- closeMoviePanel
// movie panelを閉じる
-(void) closeMoviePanel
{
	if([_moviePanel superview] != nil){		
		[_qtView pause:self];
		[_qtView setMovie:nil];
		NSRect movieRect = [_moviePanel frame];
		NSRect contentsRect = [_textContentsView frame];
	
		contentsRect.size.height += movieRect.size.height;
		[_textContentsView setFrame:contentsRect];
		[_moviePanel removeFromSuperview];
	}
}


#pragma mark Charactor Code
//-- currentCharactorElement
// 現在選択されている外字フォント
-(FontTableElement*) currentCharactorElement
{
	return _currentCharactorElement;	
}


//-- setCurrentCharactorElement
// 外字フォントの設定
-(void) setCurrentCharactorElement:(FontTableElement*) element
{
	if(element != _currentCharactorElement){
		[_currentCharactorElement release];
		_currentCharactorElement = [element retain];
	}
}


//--- showCharactorCodeImage
// 外字Drawerに外字フォントを表示する
-(void) showCharactorCode:(EBLocation) location;
{
	[self showCharactorCodePane];
	EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:location.ebook];
	
    int kind = (location.page == page_NarrowFont) ? kFontTypeNarrow : kFontTypeWide;
    int code = location.offset;
	
	[self setCurrentCharactorElement:[eb fontTableElementWithCode:code kind:kind]];
	[[_charactorCodeString window] makeFirstResponder:_charactorCodeString];
}


//--- showCharactorCodePane
// 外字ビューワを表示する
-(void) showCharactorCodePane
{
	if(!_charactorCodeView){
		if (![NSBundle loadNibNamed:@"GaijiPanel" owner:self]){ 
			NSLog(@"Failed to load GaijiPanel.nib");
			NSBeep();
		}
		[_charactorCodeView setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"backgroundPattern"]]];
		[_charactorCodeString bind:@"fontName"
						  toObject:[PreferenceModal sharedPreference]
						withKeyPath:kContentsFont
						   options:[NSDictionary dictionaryWithObject:@"FontNameToFontFamilyTransformer"
															   forKey:@"NSValueTransformerName"]];
	}
	if([_charactorCodeView superview] == nil){
		NSRect ccRect = [_charactorCodeView frame];
		NSRect svRect = [_textContentsView frame];
		svRect.size.height -= ccRect.size.height;
		svRect.origin.y += ccRect.size.height;
		ccRect.size.width = svRect.size.width;
		ccRect.origin.x = ccRect.origin.y = 0;
		[_contentsView addSubview:_charactorCodeView];
		[_charactorCodeView setFrame:ccRect];
		[_textContentsView setFrame:svRect];
	}
	[_charactorCodeView setNeedsDisplay:YES];
}


//-- closeCharactorCodePane
// 外字Paneを閉じる
-(void) closeCharactorCodePane
{
	if([_charactorCodeView superview]){
		NSRect ccRect = [_charactorCodeView frame];
		NSRect svRect = [_textContentsView frame];
		svRect.size.height += ccRect.size.height;
		svRect.origin.y = 0;
		[_textContentsView setFrame:svRect];	
		
		[_charactorCodeView removeFromSuperview];
	}
}


//-- setShowGaijiCode
// 外字を表示するかどうかの設定
-(void) setShowGaijiCode:(BOOL) shown
{
	_showGaijiCode = shown;
    [self reloadContents];
    
    if(!_showGaijiCode){
        [self closeCharactorCodePane:self];
	}
}


//-- showGaijiCode
// 外字コードを表示させるかどうか
-(BOOL) showGaijiCode
{
	return _showGaijiCode;
}


//-- setContentsConinuity
// 連続表示を行うかどうかの設定
-(void) setContentsConinuity:(BOOL) coninuity
{
	_contentsConinuity = coninuity;
    [self reloadContents];
	[[PreferenceModal sharedPreference] setValue:[NSNumber numberWithBool:_contentsConinuity] forKeyPath:kContentsConinuity];
}


//-- contentsConinuity
// 連続表示を行うかどうかを表示させるかどうか
-(BOOL) contentsConinuity
{
	return _contentsConinuity;
}


//-- changeCharactorCode
// 外字の変更
-(void) changeCharactorCode
{
	[self reloadContents];
}



#pragma mark NSTextView Delegate
//-- textView:clickedOnLink:atIndex
// リンクをクリックされた時に呼び出される
-(BOOL) textView:(NSTextView*) textview
   clickedOnLink:(id) link
		 atIndex:(NSUInteger) charindex
{
    BOOL returnCode = NO;
    
	if([link isKindOfClass:[NSURL class]]){
		NSURL* url = (NSURL*)[link copyWithZone:[self zone]];
		
		NSString* scheme = [url scheme];
		if([scheme isEqualToString:@"ebgaiji"]){
			EBLocation location = [self locationFromURL:url];
			[self showCharactorCode:location];
			returnCode = YES;
		}else if([scheme isEqualToString:@"eb"]){
			[self setContentURL:url appendHistory:YES refleshCache:YES];
			returnCode = YES;
		}else if([scheme isEqualToString:@"ebwave"]){
			[self playWave:url];
			returnCode = YES;
		}else if([scheme isEqualToString:@"ebmovie"]){
			[self playMovie:url];
            returnCode = YES;
		}
        [url release];
        
	}
	return returnCode;
}



#pragma mark WebKit Delegate

//-- webView:didCommitLoadForFrame:
// 
-(void)             webView:(WebView*)sender 
      didFinishLoadForFrame:(WebFrame*)frame
{

    if ([sender mainFrame] == frame) {
        NSView* clipView = [[[_webview mainFrame] frameView] documentView];
        NSRect webFrameRect = [clipView bounds];
        NSRect webViewRect = [_webview frame];
        
        float scale = webViewRect.size.width / webFrameRect.size.width;
        WebViewAnimation* animation = [[[WebViewAnimation alloc] initWithWebView:_webview duration:0.2 animationCurve:NSAnimationLinear] autorelease];
        [animation setScale:scale];
        [animation setAnimationBlockingMode:NSAnimationNonblocking];
        [animation startAnimation];
        /*NSSize size = [[clipView superview] convertSize:NSMakeSize(1.0f, 1.0f) fromView:nil];
        [[clipView superview] scaleUnitSquareToSize:size];
        [[clipView superview] scaleUnitSquareToSize:NSMakeSize(scale, scale)];
        [[clipView superview] setNeedsDisplay:YES];*/
    }
}


//-- webView:decidePolicyForNavigationAction:request:frame:decisionListener:
// webページの変更用
- (void)                   webView:(WebView      *) sender
   decidePolicyForNavigationAction:(NSDictionary *) info
                           request:(NSURLRequest *) request
                             frame:(WebFrame     *) frame
                  decisionListener:(id <WebPolicyDecisionListener >) listener
{
	if([[info objectForKey:WebActionNavigationTypeKey] intValue] == WebNavigationTypeLinkClicked){
		NSString* identify = [[_history currentURL] host];
		id dictionary = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:identify];
		if(dictionary && [dictionary isKindOfClass:[NetDictionary class]]){
			if([dictionary isDictionaryHost:[[request URL] host]]){
				[listener use];
				NSURL* historyURL = 
					[NSURL URLWithString:[NSString stringWithFormat:@"web://%@/%@", identify, [[request URL] absoluteString]]];
				[self addLocationHistory:historyURL];
				if([_history currentURL] != historyURL){
					[_history setCurrentURL:historyURL];
				}
			}else{
				[listener ignore];
				NSDictionary  *asErrDic = nil;
				NSAppleScript *as = [[NSAppleScript alloc] initWithSource:
									 [NSString stringWithFormat:@"open location \"%@\"", [[request URL] absoluteString]]];
				[as executeAndReturnError:&asErrDic];
				[as autorelease];
			}
			return;
		}
	}
	[listener use];
}


//-- locationFromURL
// パスからlocationを抽出する
-(EBLocation) locationFromURL:(NSURL*) url
{
	NSArray* path = [[url path] pathComponents];
	EBLocation location;
	
	if([path count] == 4){
		int ebookNumber = [[path objectAtIndex:1] intValue];
		int page = [[path objectAtIndex:2] intValue];
		int offset = [[path objectAtIndex:3] intValue];
	
		location = EBMakeLocation(ebookNumber, page, offset);
	}
	
	return location;
}


//-- webView:didFailLoadWithError:forFrame:
// エラー処理
-(void)			 webView:(WebView *)sender
	didFailLoadWithError:(NSError *)error
				forFrame:(WebFrame *)frame
{
	[self showErrorPage:error forFrame:frame];
}


//-- webView:didFailProvisionalLoadWithError:forFrame:
// エラー処理
- (void)					webView:(WebView*)webView 
	didFailProvisionalLoadWithError:(NSError*)error 
							forFrame:(WebFrame*)frame
{
	[self showErrorPage:error forFrame:frame];
}


//-- showErrorPage
// エラーページを作成し表示する
-(void) showErrorPage:(NSError*) error
			forFrame:(WebFrame*) frame
{
	NSString* domain = [error domain];
    NSInteger code = [error code];
    if (([domain isEqualToString:NSURLErrorDomain] && code == NSURLErrorCancelled) || 
        ([domain isEqualToString:WebKitErrorDomain] && code == WebKitErrorFrameLoadInterruptedByPolicyChange)){
        return;
    }
    
	NSString* path = MakeHtmlFolder();
	path = [path stringByAppendingPathComponent:@"error.html"];
	NSString* html = [self createErrorHtml:error];
	NSError* err;
	if(![html writeToFile:path atomically:YES encoding:NSUTF8StringEncoding  error:&err]){
		NSLog(@"%@", [err localizedDescription]);
		return;
	}
    [frame loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}



//-- createErrorHtml
// エラー処理
-(NSString*) createErrorHtml:(NSError*) error
{
	NSMutableString* html = [[NSMutableString alloc] init];
	[html appendString:@"<html><head>"
						@"<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>"
						@"<link rel='stylesheet' href='styles.css' type='text/css'>"];
	[html appendFormat:@"<title>%@</title>", [error localizedDescription]];
	[html appendString:@"</head><body><div class=\"error-container\">"];
	[html appendFormat:@"<p class=\"error-title\">%@</p>", [error localizedDescription]];
	if([error localizedRecoverySuggestion]){
		[html appendFormat:@"<p class=\"error-message\">%@</p>", [error localizedRecoverySuggestion]];
	}
	[html appendString:@"</div></body></html>"];
	
	return [html autorelease];
}



#pragma mark Binding
//-- observeValueForKeyPath:ofObject:change:context:
// 文字設定の変更を監視する
-(void) observeValueForKeyPath : (NSString *) keyPath
					  ofObject : (id) object
						change : (NSDictionary *) change
					   context : (void *) context
{	
	if(context == EBContentFontBindingsIdentifier){
		[self reloadContents];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark Notification
//-- contentBoundsDidChange
// スクローラのトレース
-(void) contentBoundsDidChange:(NSNotification*) notify
{
	if ([[PreferenceModal prefForKey:kAutoFowardingContents] boolValue] == NO) return;
	
    NSInteger detaction = [self isOvercrollingContents];
    if([self contentsConinuity] && detaction != 0 && [self hasContents:detaction]){
        if([_appendTimer userInfo] == nil || [[_appendTimer userInfo] intValue] != detaction){
            [self stopAppendTimer];
            _appendTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5f
                                                             target:self
                                                           selector:@selector(timeoutOverScrollingTimer:)
                                                           userInfo:[NSNumber numberWithInt:detaction]
                                                            repeats:NO] retain];
        }
    }else{
        [self stopAppendTimer];
    }
}


//-- hasContents
// 上下にコンテンツがあるかどうか
-(BOOL) hasContents:(NSInteger) detaction
{
    return (detaction == DIRECTION_OVER_BOTTOM && _hasSerialContents == true)
            || (detaction == DIRECTION_OVER_TOP && _hasBackwordContents == true);
}


//-- timeoutOverScrollingTimer
// 一定時間OverScrollingしていたときの処理
-(void) timeoutOverScrollingTimer:(NSTimer*) timer
{
    int direction = [[timer userInfo] intValue];
    [self stopAppendTimer];	
    [self appendEBookContents:direction];
}


@end
