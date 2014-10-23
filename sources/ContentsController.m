//	ContentsController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <WebKit/WebKit.h>

#import "ContentsController.h"
#import "EBookController.h"
#import "DictionaryListItem.h"
#import "DictionaryManager.h"
#import "DictionaryBinderManager.h"
#import "DictionaryBinder.h"
#import "EBook.h"
#import "PreferenceModal.h"
#import "WebViewController.h"
#import "WindowController.h"
#import "NavibarView.h"
#import "PlayerViewController.h"

#import "EBStyleSheet.h"
#import "FontTableElement.h"
#import "NetDictionary.h"
#import "EBookUtilities.h"
#import "SwipeView.h"
#import "ContentsHistory.h"
#import "GaijiPopoverController.h"

//#import "objc/runtime.h"

NSString* const EBContentFontBindingsIdentifier = @"contentFont";
NSString* const EBTextOrientationIdentifier = @"textOrientation";

NSInteger const OVERSCROLL_MARGIN = 12;
NSInteger const DIRECTION_OVER_TOP = -1;
NSInteger const DIRECTION_OVER_BOTTOM = 1;

@implementation ContentsController
@synthesize history = _history;
@synthesize textFinder = _textFinder;

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
        [[PreferenceModal sharedPreference] addObserver:self
                                             forKeyPath:kTextOrientation
                                                options:NSKeyValueObservingOptionNew
                                                context:(void*)EBTextOrientationIdentifier];
        
        _contentsConinuity = [[PreferenceModal prefForKey:kContentsConinuity] boolValue];
	
        _history = [[ContentsHistory alloc] init];
        self.webviewController = nil;
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
    //[_textContentsView setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"backgroundPattern"]]];
    
    [self refleshTextOrientation];
    self.textFinder = [[NSTextFinder alloc] init];
}


//-- dealloc
//
- (void)dealloc
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsFont];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kIndexColor];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsColor];
    [[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kTextOrientation];
	
	
}


//-- finalize
//


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





//-- closeMoviePanel
-(IBAction)closeMoviePanel:(id)sender
{
    [self closeMoviePanel];
}


#pragma mark Contents
//-- setContentView:
//  表示viewを指定する
-(void) setContentView:(NSView*) view
{
    if(_webviewController) {
        [_webviewController stopLoading];
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
    [_largeButton setHidden:![view isKindOfClass:[WebView class]]];
	[_smallButton setHidden:![view isKindOfClass:[WebView class]]];
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
    
    NSNumber* underLine = [NSNumber numberWithInt:(_isTextOrientationVertical == YES ? NSUnderlineStyleNone : NSUnderlineStyleSingle)];
    
	NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									contentsFont,							NSFontAttributeName,
									contentsColor,							NSForegroundColorAttributeName, nil];
	CGFloat gap = [contentsFont ascender] - [scriptFont ascender];
	NSDictionary* superscriptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										   scriptFont,						NSFontAttributeName,
										   contentsColor,					NSForegroundColorAttributeName,
										   [NSNumber numberWithFloat:gap],	NSBaselineOffsetAttributeName, nil];
	gap = [scriptFont descender] - [contentsFont descender];
	NSDictionary* subscriptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										 scriptFont,						NSFontAttributeName,
										 contentsColor,						NSForegroundColorAttributeName,
										 [NSNumber numberWithFloat:gap],	NSBaselineOffsetAttributeName, nil];
	NSInteger imageHeight = ceil([contentsFont ascender] - [contentsFont descender]);
	NSDictionary* emphasisAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										contentsColor,									 NSForegroundColorAttributeName,
										contentsFont,									 NSFontAttributeName,
										underLine,                                       NSUnderlineStyleAttributeName, nil];
	NSDictionary* keywordAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									   contentsFont,									 NSFontAttributeName,
									   [PreferenceModal colorForKey:kIndexColor],		 NSForegroundColorAttributeName, nil];
	NSDictionary* gaijiAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									 scriptFont,										NSFontAttributeName,
									 [NSNumber numberWithFloat:-2.0],					NSBaselineOffsetAttributeName,
									 underLine,                                         NSUnderlineStyleAttributeName, nil];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			superscriptAttributes,							EBSuperScriptAttributes,
			subscriptAttributes,							EBSubScriptAttributes,
			keywordAttributes,								EBKeywordAttributes,
			gaijiAttributes,								EBGaijiAttributes,
			emphasisAttributes,								EBEmphasisAttributes,
			textAttributes,									EBTextAttributes,
			[NSNumber numberWithBool:_showGaijiCode],		EBShowGaijiCode,
			[NSNumber numberWithBool:_contentsConinuity],	EBContentsConinuity,
			[NSNumber numberWithInteger:imageHeight],		EBFontImageHeight,
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
	 [[NSAttributedString alloc] initWithString:@""]];
	[[_textView textStorage] endEditing];
    [self adjustTextViewSize];
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
    [self adjustTextViewSize];
    
	
    if([self contentsConinuity] && ([self isOvercrollingContents] == DIRECTION_OVER_BOTTOM)  && _hasSerialContents){
		[self stopAppendTimer];
		_appendTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
														 target:self
													   selector:@selector(timeoutOverScrollingTimer:)
													   userInfo:[NSNumber numberWithInt:1]
														repeats:NO];
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
	
    NSInteger originalHeight = _isTextOrientationVertical ?
        [[_textContentsView documentView] frame].size.width : [[_textContentsView documentView] frame].size.height;
    
     [[_textView textStorage] beginEditing];
    if(direction < 0){
        [[_textView textStorage] insertAttributedString:text atIndex:0];
    }else{
        [[_textView textStorage] appendAttributedString:text];
    }
	[[_textView textStorage] endEditing];
    [self adjustTextViewSize];
    
    [self closeCharactorCodePane];
    
    NSInteger offset = _isTextOrientationVertical ?
        [[_textContentsView documentView] frame].size.width - originalHeight
        : [[_textContentsView documentView] frame].size.height - originalHeight;
    if(offset > OVERSCROLL_MARGIN &&
       ((direction == DIRECTION_OVER_TOP && _isTextOrientationVertical == NO)
        || (direction == DIRECTION_OVER_BOTTOM && _isTextOrientationVertical == YES))){
        NSClipView* clipView = [_textContentsView contentView];
        NSPoint origin = [clipView bounds].origin;
        if(_isTextOrientationVertical == YES){
            origin.x += offset;
        }else{
            origin.y += offset;
        }
        [clipView setBoundsOrigin:origin];
        if(_isTextOrientationVertical == YES){
            origin.x -= OVERSCROLL_MARGIN;
        }else{
            origin.y -= OVERSCROLL_MARGIN;
        }
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
            _appendTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector(timeoutOverScrollingTimer:)
                                                           userInfo:[NSNumber numberWithInt:1]
                                                            repeats:NO];
        }
    }
}


//-- isOvercrollingContents
// コンテンツがOverScrollingしているかどうかの判定. していない場合は0
-(NSInteger) isOvercrollingContents
{
    if ([[_textView textStorage] length] > [[PreferenceModal prefForKey:kContentsCharactersMax] intValue]) return NO;
    
    NSRect df = [[_textContentsView documentView] frame];
    NSRect cv = [[_textContentsView contentView] bounds];
    
    if(_isTextOrientationVertical == YES){
        NSRect cf = [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer];
        
        return  ((cv.origin.x - df.origin.x) < 0 || (cf.size.height < cv.size.width)) ? DIRECTION_OVER_BOTTOM
            : (df.size.width - (cv.origin.x + cv.size.width - df.origin.x)) < 0 ? DIRECTION_OVER_TOP : 0;
    }else{
        return (cv.origin.y - df.origin.y) < 0 ? DIRECTION_OVER_TOP
            : (df.size.height - (cv.origin.y + cv.size.height - df.origin.y)) <= 0 ? DIRECTION_OVER_BOTTOM : 0;
    }
}


//-- setCopyright:
// 著作権情報の表示
-(void) setCopyright:(NSURL*) url
{
	[self setContentView:_textContentsView];
	NSArray* path = [[url path] pathComponents];
	NSAttributedString* text = nil;
	if([path count] == 2){
		NSUInteger binderId = [[path objectAtIndex:1] intValue];
		DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:binderId];
		if(binder){
			text = [binder copyrightWithParamator:[self contentsParamator]];
		}
	}

	if(!text){
		text = [[NSAttributedString alloc] initWithString:@""];
	}
	[_textView scrollRangeToVisible:NSMakeRange(0,0)];
	[[_textView textStorage] beginEditing];
	[[_textView textStorage] setAttributedString:text];
	[[_textView textStorage] endEditing];
    [self adjustTextViewSize];
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
		text = [[NSAttributedString alloc] initWithString:@""];
	}
	[_textView scrollRangeToVisible:NSMakeRange(0,0)];
	[[_textView textStorage] beginEditing];
	[[_textView textStorage] setAttributedString:text];
	[[_textView textStorage] endEditing];
    [self adjustTextViewSize];
    
    
	[_windowController setResultsArray:[NSArray array]];
}


//-- setWebContents:
// Webコンテンツの表示
-(void) setWebContents:(NSURL*) url
{
	if(!self.webviewController){
        WebViewController* webViewController = [[WebViewController alloc] init];
        self.webviewController = webViewController;
        [webViewController loadView];
        webViewController.history = _history;
        webViewController.indicator = _progressIndicator;
        
        WebView* webview = [self.webviewController webview];
		[EBStyleSheet sharedStyleSheet];
		
        [_largeButton setAction:@selector(makeTextLarger:)];
		[_largeButton setTarget:webview];
		[_largeButton bind:@"enabled" toObject:webview withKeyPath:@"canMakeTextLarger" options:nil];
		[_smallButton setAction:@selector(makeTextSmaller:)];
		[_smallButton setTarget:webview];
		[_smallButton bind:@"enabled" toObject:webview withKeyPath:@"canMakeTextSmaller" options:nil];
	}
	
	NSString* urlString = [url absoluteString];
	NSString* hostname = [url host];
	if(hostname && urlString){
		NSRange scheme = [urlString rangeOfString:hostname];
		NSString* path = [urlString substringFromIndex:(scheme.location + scheme.length + 1)]; // 最初の1文字(/)を削除

		[self setContentView:self.webviewController.view];
        [self.webviewController loadURL:[NSURL URLWithString:path]];
	}
}


//-- reloadContents
// reload the current contents
-(void) reloadContents
{
    [self setContentURL:[_history currentURL] appendHistory:NO refleshCache:NO];
}



//-- refleshTextOrientation
//
-(void) refleshTextOrientation
{
    TextOrientation orientation = [[PreferenceModal prefForKey:kTextOrientation] intValue];
    if(_textView.layoutOrientation == (orientation == kTextOrientationVertical ?
                                       NSTextLayoutOrientationVertical : NSTextLayoutOrientationHorizontal)){
        return;
    }
    
    [self setEmptyContents];
    if(orientation == kTextOrientationVertical){
        _textView.layoutOrientation = NSTextLayoutOrientationVertical;
        _textView.enclosingScrollView.hasHorizontalScroller = YES;
        _textView.horizontallyResizable = YES;
        _textView.textContainer.widthTracksTextView = YES;
        
        _textView.enclosingScrollView.hasVerticalScroller = NO;
        _textView.verticallyResizable = NO;
        _textView.textContainer.heightTracksTextView = NO;
        
        //_textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        
        //_textView.textContainer.containerSize = NSMakeSize(FLT_MAX, _textView.frame.size.height);
        
        self.isTextOrientationVertical = YES;
    }else{
        _textView.layoutOrientation = NSTextLayoutOrientationHorizontal;
        _textView.enclosingScrollView.hasHorizontalScroller = NO;
        _textView.horizontallyResizable = NO;
        _textView.textContainer.widthTracksTextView = YES;
        
        _textView.enclosingScrollView.hasVerticalScroller = YES;
        _textView.verticallyResizable = YES;
        _textView.textContainer.heightTracksTextView = NO;
        
        //_textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        //_textView.textContainer.containerSize = NSMakeSize(_textView.frame.size.width, FLT_MAX);
        
        self.isTextOrientationVertical = NO;
    }
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
    return _isTextOrientationVertical == YES
        ? NO :((offset < 0 && [_history canBackHistory]) || (offset > 0 && [_history canForwardHistory]));
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





//-- searchInContent
// 本文表示エリアの中を検索する
-(IBAction) searchInContent:(id)sender
{
    NSString* searchString = [_searchField stringValue];
    
	if([_textContentsView window] != nil){
		[self searchInTextContent];
	}
	if([[_webviewController view] window] != nil){
        [_webviewController searchInContent:searchString];
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
    NSUInteger length = [contentString length];
    NSRange searchRange = NSMakeRange(0, [contentString length]);
	NSUInteger rangeNum = 0;
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
    /*
     
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
	}*/
    NSArray* path = [[url path] pathComponents];
    if([path count] == 6){
        int ebookNumber = [[path objectAtIndex:1] intValue];
        EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:ebookNumber];
        NSData* data = [eb soundWithPath:[url path]];
       
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"kotonoko.wav"];
        [data writeToFile:path atomically:NO];
        
        if(!self.playerViewController){
            self.playerViewController = [[PlayerViewController alloc] init];
        }
        
        [self.playerViewController playMovie:path over:_textContentsView];
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
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"kotonoko.mpg"];
        [data writeToFile:path atomically:NO];
        
        if(!self.playerViewController){
            self.playerViewController = [[PlayerViewController alloc] init];
        }
        
        [self.playerViewController playMovie:path over:_textContentsView];
	}
}




//-- closeMoviePanel
// movie panelを閉じる
-(void) closeMoviePanel
{
    if(self.playerViewController){
        [self.playerViewController closePanel:_textContentsView];
    }
}


#pragma mark Charactor Code
//-- closeCharactorCodePanel
//
-(void) closeCharactorCodePane
{
    if(_gaijiPopoverController){
        [_gaijiPopoverController closePopover];
    }
}

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
		_currentCharactorElement = element;
	}
}


//--- showCharactorCodeImage
// 外字Drawerに外字フォントを表示する
-(void) showCharactorCode:(EBLocation) location inRect:(NSRect)rect
{
	EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:location.ebook];
	
    NSInteger kind = (location.page == page_NarrowFont) ? kFontTypeNarrow : kFontTypeWide;
    NSInteger code = location.offset;
	
	[self setCurrentCharactorElement:[eb fontTableElementWithCode:code kind:kind]];
    
    [self showCharactorCodePaneInRect:rect];
}


//--- showCharactorCodePane
// 外字ビューワを表示する
-(void) showCharactorCodePaneInRect:(NSRect)rect
{
    if(!_gaijiPopoverController){
        _gaijiPopoverController = [[GaijiPopoverController alloc] init];
        
        _gaijiPopoverController.popover.delegate = self;
        _gaijiPopoverController.popover.animates = YES;
        _gaijiPopoverController.popover.behavior = NSPopoverBehaviorSemitransient;
    }
    _gaijiPopoverController.representedObject = _currentCharactorElement;
    [_gaijiPopoverController showPopoverRelativeToRect:rect ofView:_textView];
}





//-- setShowGaijiCode
// 外字を表示するかどうかの設定
-(void) setShowGaijiCode:(BOOL) shown
{
	_showGaijiCode = shown;
    [self reloadContents];
    
    if(!_showGaijiCode){
        [self closeCharactorCodePane];
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
		NSURL* url = (NSURL*)[link copyWithZone:nil];
		
		NSString* scheme = [url scheme];
		if([scheme isEqualToString:@"ebgaiji"]){
			EBLocation location = [self locationFromURL:url];
            NSRange textRange = [[textview layoutManager] glyphRangeForCharacterRange:NSMakeRange(charindex, 1) actualCharacterRange:nil];
            NSRect layoutRect = [[textview layoutManager] boundingRectForGlyphRange:textRange inTextContainer:[textview textContainer]];
            
            NSPoint containerOrigin = [textview textContainerOrigin];
            layoutRect.origin.x += containerOrigin.x;
            layoutRect.origin.y += containerOrigin.y;

            [self showCharactorCode:location inRect:layoutRect];
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
        
	}
	return returnCode;
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


#pragma mark Binding
//-- observeValueForKeyPath:ofObject:change:context:
// 文字設定の変更を監視する
-(void) observeValueForKeyPath : (NSString *) keyPath
					  ofObject : (id) object
						change : (NSDictionary *) change
					   context : (void *) context
{
	if(context == (__bridge void *)(EBContentFontBindingsIdentifier)){
		[self reloadContents];
    }else if(context == (__bridge void*)(EBTextOrientationIdentifier)){
        [self refleshTextOrientation];
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
            _appendTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                             target:self
                                                           selector:@selector(timeoutOverScrollingTimer:)
                                                           userInfo:[NSNumber numberWithInteger:detaction]
                                                            repeats:NO];
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


//-- adjustTextViewSize
// NSTextViewのサイズを合わせる
-(void) adjustTextViewSize
{
    [_textView sizeToFit];
    
    if(_isTextOrientationVertical){
        NSRect frame = [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer];
        NSRect bounds = _textView.bounds;
        if(bounds.size.height < frame.size.height){
            _textView.frame = NSMakeRect(0, 0, frame.size.height, frame.size.width);
        }
    }
}

#pragma mark -
#pragma mark NSPopoverDelegate


//-- popoverDidClose
//
- (void)popoverDidClose:(NSNotification *)notification
{
    [self reloadContents];
}




@end
