//	WindowController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "EBook.h" // for EB...Attributes
#import "ELDefines.h"
#import "PreferenceModal.h"
#import "EBookController.h"
#import "ContentsView.h"
#import "WindowController.h"
#import "SearchViewController.h"
#import "MultiSearchViewController.h"
#import "ProgressPanel.h"
#import "LinerMatrix.h"
#import "DictionaryBinder.h"
#import "ContentsController.h"
#import "DictionaryBinderManager.h"
#import "VerboseFieldEditer.h"
#import "DictionaryElement.h"

#define abs(c) ((c) < 0 ? -(c) : (c))

void* kWindowStyleBindingIdentifier = (void*) @"windowStyle";
void* kHeadingFontBindingsIdentifier = (void*) @"headingFont";

@implementation WindowController
//-- initWithController
// 初期化ルーチン
- (id) initWithController:(EBookController*)inController
{
    self = [super init];
    
    if(self){
        _ebookController = inController;
		_searchMethod = -1;
	    [self createMainWindow];
    }
    
    return self;
}


//-- dealloc
// メモリの開放
- (void) dealloc
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kWindowStyle];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kHeadingFont];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kHeadingColor];

	[_fieldEditer release];
	[_resultsArray release];
	[super dealloc];
}


//-- finalize
// 後片付け
- (void) finalize
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kWindowStyle];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kHeadingFont];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kHeadingColor];	
	[super finalize];
}


//-- createMainWindow
// nib から mainwindowを生成する
- (void) createMainWindow
{
    if(!_window){
        if (![NSBundle loadNibNamed:@"MainWindow" owner:self]){ 
			NSLog(@"Failed to load MainWindow.nib");
			NSBeep();
		}
		
		[self setWindowTitle:nil];
		[_searchClip setBackgroundColor:[NSColor windowBackgroundColor]];
		// 検索Viewを初期化する
		_searchViewController = [[SearchViewController alloc] initWithWindowController:self];
		[self setSearchView:[_searchViewController view]];
		_currentSearchViewController = _searchViewController;
        
        [_headingTable setFloatsGroupRows:YES];
	}
    [_window makeKeyAndOrderFront:nil];
}



//-- createWindowContent
// ウィンドウの中身を作る
-(void) createWindowContent
{
	[[PreferenceModal sharedPreference] addObserver:self forKeyPath:kWindowStyle
											options:NSKeyValueObservingOptionNew context:kWindowStyleBindingIdentifier];
	[self syncWindowStyle];
	
	[_binderController bind:@"filterPredicate"
				   toObject:[DictionaryBinderManager sharedDictionaryBinderManager]
				withKeyPath:@"quickTagFilterPredicate"
					options:nil];
	NSRect frame = [(NSView*)[_window contentView] frame];
	[_contentView setFrame:frame];
	[_window setContentView:_contentView];
	
	[self setContentsViewToDictionaryContents];

	[_binderMatrix bind:@"value" toObject:_binderController withKeyPath:@"arrangedObjects" options:nil];
	[_binderMatrix bind:@"selectedIndex" toObject:_binderController withKeyPath:@"selectionIndex" options:nil];
	
	//-- notificationの設定
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(becomeMainWindow:)
												 name:NSWindowDidBecomeKeyNotification
											   object:_window];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(searchViewAnimeFinished:)
												 name:kFinichSearchViewAnimation
											   object:self];
	[[PreferenceModal sharedPreference] addObserver:self
										 forKeyPath:kHeadingColor
											options:NSKeyValueObservingOptionNew
											context:(void*)kHeadingFontBindingsIdentifier];
	[[PreferenceModal sharedPreference] addObserver:self
										 forKeyPath:kHeadingFont
											options:NSKeyValueObservingOptionNew
											context:(void*)kHeadingFontBindingsIdentifier];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(selectHeading:)
												 name:NSTableViewSelectionDidChangeNotification
											   object:_headingTable];
}



#pragma mark -
#pragma mark Window
//-- setWindowTitle
// ウィンドウタイトルの設定
- (void) setWindowTitle : (NSString*) inTitle
{
	if(inTitle){
		[_window setTitle:inTitle];
	}else{
		[_window setTitle:NSLocalizedString(@"Application Name", @"kotonoko")];
	}
}


#pragma mark ContentsView
//-- setContentsView
// コンテンツviewの設定
-(void) setContentsView:(NSView*) contentsView;
{
	if ([self currentContentsView] == contentsView) return;
	
	// サイズを合わせて設定する
	[contentsView setFrame:[_contentsClip frame]];
	
	// 既に含まれているsubviewをfadeoutさせる
	NSArray* subviews = [_contentsClip subviews];
	NSMutableArray* animations = [[NSMutableArray alloc] initWithCapacity:([subviews count] + 1)];
	for(NSView* view in subviews){
		if(view != contentsView){
            NSRect frame = [view frame];
			NSDictionary* fadeout = [NSDictionary dictionaryWithObjectsAndKeys:
									 view, NSViewAnimationTargetKey,
                                     [NSValue valueWithRect:frame], NSViewAnimationStartFrameKey,
                                     [NSValue valueWithRect:NSOffsetRect(frame, 0, frame.size.height/2)],NSViewAnimationEndFrameKey,
									 NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
			[animations addObject:fadeout];
		}
	}
	
	[_contentsClip addSubview:contentsView];
	NSDictionary* fadein = [NSDictionary dictionaryWithObjectsAndKeys:
							contentsView, NSViewAnimationTargetKey,
							NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
							nil];
	[animations addObject:fadein];
	NSViewAnimation* viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
	[viewAnimation setDuration:0.5];
	[viewAnimation setAnimationCurve:NSAnimationEaseIn];
	[viewAnimation setDelegate:self];
	[viewAnimation startAnimation];
	[viewAnimation release];
	[animations release];
}


//-- animationDidEnd:
// アニメーションの終了時に呼び出される
-(void)animationDidEnd:(NSAnimation *)animation
{
	// フェードアウトしたviewをsuper viewから取り除く
	if([animation isKindOfClass:[NSViewAnimation class]]){
		NSArray* animations = [(NSViewAnimation*)animation viewAnimations];
		for(NSDictionary* anima in animations){
			if([anima objectForKey:NSViewAnimationEffectKey] == NSViewAnimationFadeOutEffect){
				NSView* view = [anima objectForKey:NSViewAnimationTargetKey];
				[view removeFromSuperview];
			}
		}
	}
}


//-- currentContentsView
// 現在のcontents viewを返す
-(NSView*) currentContentsView
{
	return [[_contentsClip subviews] lastObject];
}


//-- setContentsViewToDictionaryContents
// contents viewを辞書内容に変更する
-(void) setContentsViewToDictionaryContents
{
	[self setContentsView:_splitView];
}


#pragma mark SearchView
//-- setSearchView
// search viewの設定
- (void) setSearchView:(NSView*)inSearchView 
{
    [self setSearchView:inSearchView withAnime:NO];
}


//-- setSearchView:withAnime
// search viewの設定
- (void) setSearchView:(NSView*)inSearchView withAnime:(BOOL)isAnime
{
    if (_searchView == inSearchView) return;
        
    if(isAnime){
        NSRect clip_frame, view_frame;
        // 横幅は合わせる
        clip_frame = [_searchClip frame];
        view_frame = [inSearchView frame];
        view_frame.size.width = clip_frame.size.width;
        view_frame.origin.x = view_frame.origin.y = 0.0;
        [inSearchView setFrame:view_frame];
        // もしタイマが動いていたら止める
        if(_searchViewAnimeTimer){
            [_searchViewAnimeTimer invalidate];
            _searchViewAnimeTimer = nil;
        }
        _searchViewAnimeTimer = [NSTimer scheduledTimerWithTimeInterval : 0.01
                                                                 target : self
                                                               selector : @selector(searchViewAnime:)
                                                               userInfo : nil
                                                                repeats : YES ];
    }else{
        [inSearchView setFrame:[_searchClip frame]];
    }
    [_searchClip setDocumentView:inSearchView];
    _searchView = inSearchView;
}


//-- searchViewAnime
// serachView変更時のアニメーション
- (void) searchViewAnime : (id) inUserInfo
{
    NSRect top_frame, bottom_frame, frame;
    CGFloat diff = 0.0;
    
    top_frame = [_searchClip frame];
    bottom_frame = [_splitView frame];
    frame = [_searchView frame];
    
    if(abs(top_frame.size.height - frame.size.height) < 1.0){
        [_searchViewAnimeTimer invalidate];
        _searchViewAnimeTimer = nil;
        diff = frame.size.height - top_frame.size.height;
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kFinichSearchViewAnimation object:self userInfo:nil];
    }else if(abs(top_frame.size.height - frame.size.height) < 32.0){
        diff = frame.size.height - top_frame.size.height;
    }else if(top_frame.size.height < frame.size.height){
        diff = 32.0;
    }else if(top_frame.size.height > frame.size.height){
        diff = -32.0;
    }
    top_frame.size.height += diff;
    bottom_frame.size.height -= diff;
    top_frame.origin.y -= diff;
    
    [_searchClip setFrame:top_frame];
    [_splitView setFrame:bottom_frame];
    
    [_window display];
}


//-- searchViewAnimeFinished
// search viewの切り替えが終了した
- (void) searchViewAnimeFinished:(NSNotification*) inNote
{
	[self moveFocusToSearchView];
}



//-- setNextKeyView
// tab chainの設定
-(void) setNextKeyView:(NSView*) view
{
	[_headingTable setNextKeyView:view];
}


//-- syncWindowStyle
// 横分割にするかどうか
- (void) syncWindowStyle
{
	BOOL isVertical;
	int windowStyle = [[PreferenceModal prefForKey:kWindowStyle] intValue];
	if(windowStyle == kWindowStyleAutomatic){
		NSSize size = [_window frame].size;
		isVertical = (size.width > [[PreferenceModal prefForKey:kWSSwitchingWidth] intValue]);
	}else{
		isVertical = (windowStyle == kWindowStyleVertical);
	}
	
    if([_splitView isVertical] != isVertical){
		CGFloat divThickness = [_splitView dividerThickness]; // 幅
        // 変換前の分割比を求めておく
        NSView* oView = [[_splitView subviews] objectAtIndex:0];
        NSRect oFrame = [oView frame];
        NSRect pFrame = [_splitView frame];
        CGFloat ratio = [_splitView isVertical] ? oFrame.size.width / pFrame.size.width
			: oFrame.size.height / pFrame.size.height;
        // 縦/横の変換を行う
        [_splitView setVertical:isVertical];
        [_splitView adjustSubviews]; // デフォルトのadjust(1:1になる)
        // 分割比を戻す
        NSView* tView = [[_splitView subviews] objectAtIndex:1];
        NSRect tFrame = [tView frame];
        oFrame = [oView frame];
        
        if(isVertical){
            oFrame.size.width = ceil(pFrame.size.width * ratio);
            tFrame.size.width =
                pFrame.size.width - oFrame.size.width - divThickness;
            tFrame.origin.x = oFrame.size.width + divThickness;
        }else{
            oFrame.size.height = ceil(pFrame.size.height * ratio);
            tFrame.size.height =
                pFrame.size.height - oFrame.size.height - divThickness;
            tFrame.origin.y = oFrame.size.height + divThickness;
        }
        //[oView setFrame:oFrame];
        //[tView setFrame:tFrame];
		
		
		
        [_splitView setNeedsDisplay:YES];
    }
}


//-- showFront
// 前面に移動する
- (void) showFront
{
    //if(_windowState == ws_MiniWindow){
	//	[mMiniWindowController moveFront];
    //}else{
        // もし最小化されていれば前面にだす
        if([_window isMiniaturized] == YES){
            [_window deminiaturize:self];
        }
        // もし隠されていたら表にだす
        if([_window isKeyWindow] == NO){
            [_window makeKeyAndOrderFront:nil];
        }
}


//-- window
// ウィンドウを返す
- (NSWindow*) window
{
    return _window;
}



//-- selectQuickTab:
// quick tagの選択タグの変更
-(void) selectQuickTab:(id) binder
{
	[_binderController setSelectedObjects:[NSArray arrayWithObject:binder]];
}



#pragma mark TableView (Heading)
//-- setInputText
// 入力文字列の設定
- (void) setInputText:(NSString*) inString
{
	[[_searchViewController inputField] setStringValue:inString];
}


//-- moveFocusToHeading
// focusをheadingに移動させる
- (void) moveFocusToHeading
{
	// Focusの移動
	if([_headingTable window]){
		[_window makeFirstResponder:_headingTable];
		
		if([self selectFirstHeading] == NO){
			[_contentsController setEmptyContents];
		}else{
            [self selectHeading:nil];
        }
    }
}


//-- selectFirstHeading
// 一番最初のHeadingアイテムを選択し、辞書内容を表示する
-(BOOL) selectFirstHeading
{
	NSUInteger i;
	BOOL selected = NO;
	for(i=1; i<[_resultsArray count]; i++){
		if([[_resultsArray objectAtIndex:i] canSelect]){
			[_headingTable selectRowIndexes:[NSIndexSet indexSetWithIndex:i]
					   byExtendingSelection:NO];
			selected = YES;
			break;
		}
	}
	return selected;
}

//-- headingParamator
// 検索結果文字列のパラメタ
-(NSDictionary*) headingParamator
{
	NSFont* contentsFont = [PreferenceModal fontForKey:kHeadingFont];
	NSFont* scriptFont = [NSFont fontWithName:[contentsFont fontName] size:([contentsFont pointSize]*0.75)];
	
	NSColor* contentsColor = [PreferenceModal colorForKey:kHeadingColor];
	
	
	NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									contentsFont,							NSFontAttributeName,
									contentsColor,							NSForegroundColorAttributeName, nil];
	
    NSFont* tagFont = [[NSFontManager sharedFontManager] convertFont:contentsFont toHaveTrait:NSBoldFontMask];
    NSColor* tagColor = [PreferenceModal colorForKey:kDictionaryNameColor];
    NSMutableParagraphStyle *paragraph = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
    
	NSDictionary* tagAttributes;
    if([tagFont pointSize] > 10.0f){
        NSShadow* tagShadow = [[[NSShadow alloc] init] autorelease];
        [tagShadow setShadowColor:[NSColor blackColor]];
        [tagShadow setShadowOffset:NSMakeSize(0.0f, -1.0f)];
        [tagShadow setShadowBlurRadius:1.0f];
        tagAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
								   tagFont,							NSFontAttributeName,
                                   tagColor,						NSForegroundColorAttributeName,
                                   tagShadow,                       NSShadowAttributeName,
                                   paragraph,                       NSParagraphStyleAttributeName,
                                   nil];
    }else{
        tagAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                         tagFont,						NSFontAttributeName,
                         tagColor,						NSForegroundColorAttributeName,
                         paragraph,                     NSParagraphStyleAttributeName,
                         nil];
    }
	CGFloat gap = [contentsFont ascender] - [scriptFont ascender];
	NSDictionary* superscriptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										   scriptFont, NSFontAttributeName,
										   [NSNumber numberWithFloat:gap], NSBaselineOffsetAttributeName,
										   nil];
	gap = [scriptFont descender] - [contentsFont descender];
	NSDictionary* subscriptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										 scriptFont, NSFontAttributeName,
										 [NSNumber numberWithFloat:gap], NSBaselineOffsetAttributeName,
										 nil];
	NSInteger imageHeight = ceil([contentsFont ascender] - [contentsFont descender]);
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			superscriptAttributes,					EBSuperScriptAttributes,
			subscriptAttributes,					EBSubScriptAttributes,
			textAttributes,							EBTextAttributes,
			tagAttributes,							EBTagAttributes,
			[NSNumber numberWithInteger:imageHeight],	EBFontImageHeight, nil];
}


#pragma mark Font

//-- updateHeadingFont
// heading font の設定
-(void) updateHeadingFont
{
	NSFont* font = [PreferenceModal fontForKey:kHeadingFont];
	NSLayoutManager* lm = [[NSLayoutManager alloc] init];
	[_headingTable setRowHeight:([lm defaultLineHeightForFont:font] + 2.0)];
    
	[_currentSearchViewController research];
	[lm release];
}


#pragma mark Printing
//-- runPageLayout
// 用紙設定ダイアログの表示
- (void) runPageLayout
{
    NSPageLayout *pageLayout = [NSPageLayout pageLayout];
    [pageLayout beginSheetWithPrintInfo : [NSPrintInfo sharedPrintInfo]
						 modalForWindow : _window
							   delegate : nil
						 didEndSelector : NULL
							contextInfo : NULL];
}


//-- print
// 印刷を行う
- (void) print
{
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:[_contentsController textView]];
    [printOperation runOperationModalForWindow : _window
									  delegate : nil
								didRunSelector : NULL
								   contextInfo : NULL];
}

#pragma mark -
#pragma mark SearchMethod
//--- changeSearchMethod
// 検索方法の変更
- (void) changeSearchMethod : (ESearchMethod) inMethod
{
	_searchMethod = inMethod;
	
	NSArray* searchMethods = [[self currentDictionaryBinder] searchMethods];
	
	if(_searchMethod == kSearchMethodMenu){
		[self setSearchView:[_searchViewController view] withAnime:YES];
		[_searchViewController clearSearchWord];
		[_searchViewController setSearchMethods:searchMethods];
		[_searchViewController selectSearchMethodWithTag:_searchMethod];
		[_searchViewController setEnabled:NO];
		_currentSearchViewController = _searchViewController;
		NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"menu:/%ld", [_currentDictionaryBinder binderId]]];
		[_contentsController setContentURL:url appendHistory:YES refleshCache:YES];
		[self setContentsViewToDictionaryContents];
	}else if(_searchMethod < kSearchMethodMulti){
		[self setSearchView:[_searchViewController view] withAnime:YES];
		[_searchViewController setSearchMethods:searchMethods];
		[_searchViewController selectSearchMethodWithTag:_searchMethod];
		[_searchViewController setEnabled:YES];
		_currentSearchViewController = _searchViewController;
		[self setContentsViewToDictionaryContents];
	}else{ // 複合検索
		if(!_multiSearchViewController){
			_multiSearchViewController = [[MultiSearchViewController alloc] initWithWindowController:self];
		}
		[self setSearchView:[_multiSearchViewController view] withAnime:YES];
		[_multiSearchViewController setSearchMethods:searchMethods];
		[_multiSearchViewController selectSearchMethodWithTag:_searchMethod];
		_currentSearchViewController = _multiSearchViewController;
			
		[_multiSearchViewController setContentsViewToSearchEntriesView];
	}
	//[_currentSearchViewController moveFocus];
	
	if([_currentSearchViewController respondsToSelector:@selector(setNextKeyView:)]){
		[_contentsController setNextKeyView:[_currentSearchViewController firstController]];
		[_currentSearchViewController setNextKeyView:_headingTable];
	}else{
		[_contentsController setNextKeyView:_headingTable];
		//[_headingTable setNextKeyView:[_contentsController firstKeyView]];
	}
}


//-- searchMethod
// 検索手法を返す
- (ESearchMethod) searchMethod
{
	return _searchMethod;
}



#pragma mark Active Dictionary
//-- currentDictionaryBinder
// 現在選択されているbinderを返す
-(DictionaryBinder*) currentDictionaryBinder
{
	return _currentDictionaryBinder;
}


//-- currentDictionaryBinder
// 現在選択されているbinderを返す
-(void) setCurrentDictionaryBinder:(DictionaryBinder*) binder
{
	if(_currentDictionaryBinder != binder){
		[_currentDictionaryBinder release];
		_currentDictionaryBinder = [binder retain];
	}
}



#pragma mark -
#pragma mark Actions
//--- nextDictionary
// 次の辞書に移動
- (IBAction) nextDictionary : (id)sender
{
	DictionaryBinder* currentDictionaryBinder = [self currentDictionaryBinder];
	DictionaryBinder* binder = [[DictionaryBinderManager sharedDictionaryBinderManager]
								nextBinder:currentDictionaryBinder];
	[self selectBinder:binder];
}


//--- privDictionary
// 前の辞書に移動
- (IBAction) privDictionary : (id)sender
{
	DictionaryBinder* currentDictionaryBinder = [self currentDictionaryBinder];
	DictionaryBinder* binder = [[DictionaryBinderManager sharedDictionaryBinderManager] 
								privBinder:currentDictionaryBinder];
	[self selectBinder:binder];
}


//-- handleMenuSelection
// メニュー項目が選択された時の処理
-(IBAction) handleMenuSelection:(id) sender
{
	DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:[sender tag]];
	[self selectBinder:binder];
}


//-- changeDictionary
// Quick Tagからの辞書の変更
-(IBAction) changeDictionary:(id)sender
{
	DictionaryBinder* binder = [[_binderController selectedObjects] objectAtIndex:0];
	[self selectBinder:binder];
}


//-- selectDictionary
// 辞書の変更
-(void) selectBinder:(DictionaryBinder*) binder
{
	if(binder){
		[self setCurrentDictionaryBinder:binder];
		[self selectQuickTab:binder];
		if(![self adjustSearchMethod]){
			NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"copyright:/%ld", [binder binderId]]];
			[_contentsController setContentURL:url appendHistory:NO refleshCache:YES];
		}
        [self setWindowTitle:[binder tagName]];
	}
}



//-- adjustSearchMethod
// 検索手法の調整
-(BOOL) adjustSearchMethod
{
	DictionaryBinder* binder = [self currentDictionaryBinder];
	NSArray* searchMethods = [binder searchMethods];
	
	NSDictionary* firstMethod = [searchMethods objectAtIndex:0];
	[self changeSearchMethod:[[firstMethod objectForKey:@"tag"] intValue]]; //前方検索に切り替える
	
	[_headingTable deselectAll:self];
	[_currentSearchViewController moveFocus];
    if(_currentSearchViewController == _searchViewController){
		NSString* searchWord = [[_searchViewController inputField] stringValue];
		if(searchWord && [searchWord length] > 0){
			[self searchWord:[[_searchViewController inputField] stringValue]
						 max:[[PreferenceModal prefForKey:kSearchAllMax] intValue]];
			return [self selectFirstHeading];
		}
	}
	return NO;
}





//-- selectHeading
// headingを選択した時の設定
-(void) selectHeading :(NSNotification*)notification
{
    NSIndexSet* indexes = [_headingTable selectedRowIndexes];
    if(indexes.count == 1){
        NSUInteger index = indexes.firstIndex;
        id object = [_headingController.arrangedObjects objectAtIndex:index];
        if(object != nil){
            NSURL* location = [object anchor];
            [_contentsController setContentURL:location appendHistory:YES refleshCache:YES];
        }
	}
}


//-- moveFocusToContentsSearch
// focusを本文検索に渡す
-(IBAction) find:(id) sender
{
    [_contentsController moveFocusToContentsSearch];
}


//-- showGaijiCode
// 外字コードの表示を本文検索に渡す
-(IBAction) showGaijiCode:(id) sender
{
    [_contentsController setShowGaijiCode:![_contentsController showGaijiCode]];
}



#pragma mark -
#pragma mark Delegate
//-- windowWillColse
// windowを閉じる時に呼び出される
- (void) windowWillClose : (NSNotification *) inNotification
{
    if([[PreferenceModal prefForKey:kQuitWhenNoWindow] boolValue] == YES){
        [NSApp terminate:nil];
    }
}



//-- becomeMainWindow
// Windowがキーウィンドウになった時の処理
- (void) becomeMainWindow : (NSNotification *) inNotification
{
	if(!([[_window firstResponder] isKindOfClass:[NSTextView class]] &&
		 [(NSTextView*)[_window firstResponder] isEditable])){
		// focusを検索フィールドに移す
		[self moveFocusToSearchView];
	}
}


//-- windowDidResize
// windowのサイズを変更した時の処理
- (void) windowDidResize : (NSNotification *) notification
{
	[self syncWindowStyle];
}



//-- validateMenuItem
// メニューアイテムの更新
-(BOOL) validateMenuItem:(NSMenuItem*) menuItem
{
	if([menuItem action] == @selector(showGaijiCode:)){
		if([_contentsController showGaijiCode]){
			[menuItem setTitle:NSLocalizedString(@"Hide Charactor Code", @"Hide Charactor Code")];
		}else{
			[menuItem setTitle:NSLocalizedString(@"Show Charactor Code", @"Show Charactor Code")];
		}
	}else if([menuItem action] == @selector(handleMenuSelection:)){
		DictionaryBinder* currentDictionaryBinder = [self currentDictionaryBinder];
		if(currentDictionaryBinder && [menuItem tag] == [currentDictionaryBinder binderId]){
			[menuItem setState:NSOnState];
		}else{
			[menuItem setState:NSOffState];
		}
	}
	return YES;
}


- (void) moveFocusToSearchView
{
	[_currentSearchViewController moveFocus];
}


//-- searchWord:max:
// 検索して見出し語を得る
- (void) searchWord:(NSString*) inWord
				max:(NSInteger) inMaxNumber
{
	NSInteger max = inMaxNumber;
	if(max < 1){
		max = [_currentDictionaryBinder isKindOfClass:[MultiBinder class]] ? 10 : 50;
	}
	ESearchMethod method = [self searchMethod];
	NSArray* array = [_currentDictionaryBinder search:inWord method:method max:max paramator:[self headingParamator]];
	
	[self setResultsArray:array];
}


//-- searchEntries:max:
// 検索して見出し語を得る
- (void) searchEntries:(NSArray*) entries
				   max:(NSInteger) maxNumber
{
	NSInteger max = maxNumber;
	if(max < 1){ max = [_currentDictionaryBinder isKindOfClass:[MultiBinder class]] ? 10 : 50; }
	
	ESearchMethod method = [self searchMethod];
	if([_currentDictionaryBinder isKindOfClass:[SingleBinder class]]){
		NSInteger index = method - kSearchMethodMulti;
		NSArray* array = [(SingleBinder*)_currentDictionaryBinder multiSearch:entries index:index max:max paramator:[self headingParamator]];
		[self setResultsArray:array];
	}
}


//-- resultsArray
// 検索結果を返す
-(NSArray*) resultsArray
{
	return _resultsArray;
}

//-- setResultsArray
// 検索結果の設定
-(void) setResultsArray:(NSArray*) results
{
	if(results != _resultsArray){
		[_resultsArray release];
		_resultsArray = [results retain];
	}
}



//--- window:willUseFullScreenPresentationOptions:
-(NSApplicationPresentationOptions)         window:(NSWindow *)window
              willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
    return proposedOptions;
    //| NSApplicationPresentationHideDock;
//    return proposedOptions | (NSApplicationPresentationAutoHideMenuBar | NSApplicationPresentationHideDock);
}

#pragma mark Observer

//-- observeValueForKeyPath:ofObject:change:context:
// 
- (void) observeValueForKeyPath : (NSString *) keyPath
					   ofObject : (id) object
						 change : (NSDictionary *) change
						context : (void *) context
{
	if(context == kWindowStyleBindingIdentifier){
		[self syncWindowStyle];
	}else if(context == kHeadingFontBindingsIdentifier){
		[self updateHeadingFont];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


#pragma mark Progress Sheet
//-- showProgressSheet
-(void) showProgressSheet:(NSString*) caption
{
	if(!_progressPanel){
		_progressPanel = [[ProgressPanel alloc] init];
	}
	[_progressPanel beginSheetForWindow:_window caption:caption];
}


//-- hideProgressSheet
//
-(void) hideProgressSheet
{
	[_progressPanel endSheet];
}


//-- progressPanel
// return progress panel controller
-(ProgressPanel*) progressPanel
{
	return _progressPanel;
}


#pragma mark Field Editer
//-- fieldEditer
// オリジナルのフィールドエディタを返す
-(id) fieldEditer
{
	if(!_fieldEditer){
		_fieldEditer = [[VerboseFieldEditer alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		[_fieldEditer setFieldEditor:YES];
	}
	return _fieldEditer;
}


//-- windowWillReturnFieldEditor:toObject:
// フィールドエディタを返す
-(id) windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id) obj
{
	return [self fieldEditer];
}


@end
