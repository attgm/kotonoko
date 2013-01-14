//	EBookController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//
// * set next key of HeadingTable by Shiio 2002-01-31
// * service method added by Hiroshi TOMIE 2002-03-15
// * sound patch by Fujiwara Katsuya 2003-03-12

#import "FontNameToFontTransformer.h"
#import "ColorNameToColorTransformer.h"
#import "KeyEquivalentToNumberTransformer.h"
#import "FontNameToFontFamilyTransformer.h"
#import "PreferenceWindowController.h"
#import "PreferenceModal.h"

#import "EBook.h"
#import "EBookController.h"
#import "DictionaryElement.h"
#import "FontTableElement.h"
#import "ContentsView.h"
#import "HistoryDataSource.h"
#import "WindowController.h"

#import "FontPanelController.h"
#import "DictionaryManager.h"
#import "DictionaryBinderManager.h"
#import "DictionaryBinder.h"
#import "DictionaryListItem.h"
#import "PasteboardWatcher.h"

#import "AcknowledgmentsWindowController.h"

NSString* const EBPasteboardSearchBindingsIdentifier = @"pasteboardSearch";

@implementation EBookController


//--- applicationDidFinishLaunching
// アプリケーションの起動終了時に呼ばれる
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_binderManager = nil;
	_acknowledgmentsWindowController = nil;
	// ValueTransformerの登録
	[NSValueTransformer setValueTransformer:[[[FontNameToFontTransformer alloc] init] autorelease]
									forName:[FontNameToFontTransformer className]];
	[NSValueTransformer setValueTransformer:[[[ColorNameToColorTransformer alloc] init] autorelease]
									forName:[ColorNameToColorTransformer className]];
	[NSValueTransformer setValueTransformer:[[[KeyEquivalentToNumberTransformer alloc] init] autorelease]
									forName:[KeyEquivalentToNumberTransformer className]];
	[NSValueTransformer setValueTransformer:[[[FontNameToFontFamilyTransformer alloc] init] autorelease]
									forName:[FontNameToFontFamilyTransformer className]];
	// メインウィンドウの表示
    _windowController = [[WindowController alloc] initWithController:self];
    
    _hasVolumes = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(dictionaryDidFinishLunching:)
												 name:kDidInitializeDictionaryManager
											   object:nil];
	[_windowController showProgressSheet:NSLocalizedString(@"Scanning Dictionaries", @"Scan dictionaries...")];
	[[DictionaryManager sharedDictionaryManager] initialize];
	
	
	// Apple Eventの登録
    /*
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(handleSearchEvent:withReplyEvent:)
													 forEventClass:'ktNk'
														andEventID:'srch'];
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(handleListEvent:withReplyEvent:)
													 forEventClass:'ktNk'
														andEventID:'list'];
	
	*/
	
}	


//-- dictionaryDidFinishLunching
// 辞書の走査が完了したかどうかの判定
- (void) dictionaryDidFinishLunching:(NSNotification *)aNotification
{
	[self willChangeValueForKey:@"binderManager"];
	_binderManager = [DictionaryBinderManager sharedDictionaryBinderManager];
	[_binderManager sortBinderByIndex];
	[self didChangeValueForKey:@"binderManager"];
	[_windowController hideProgressSheet];
	
	[_windowController createWindowContent];
	// 辞書メニューの生成
	[_dictionaryMenuBinder bind:@"menus" toObject:_binderManager withKeyPath:@"binders" options:0];
	
	// 始めの辞書を選択する
	// 初期状態で選択される辞書の名前
    DictionaryBinder* binder = [_binderManager binderForTitle:[PreferenceModal prefForKey:kCurrentDictionary]];
	if (!binder) binder = [_binderManager firstBinder];
    [_windowController selectBinder:binder];
	
    [[NSApplication sharedApplication] setServicesProvider:self];
	
	// マウント/アンマウント通知の設定
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self selector:@selector(didMountUnmount:) name:NSWorkspaceDidMountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self selector:@selector(didMountUnmount:) name:NSWorkspaceDidUnmountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self selector:@selector(willUnmount:) name:NSWorkspaceWillUnmountNotification object:nil];
	_fontPanelController = nil;
	
	_pasteboardWatcher = [[PasteboardWatcher alloc] initWithDelegate:self];
    
    
    if([aNotification userInfo] != nil && [[[aNotification userInfo] objectForKey:kAllDictionariesIsLoaded] boolValue] == NO){
        NSRunInformationalAlertPanel(NSLocalizedString(@"Access Denied", @"Access Denied"),
                                     NSLocalizedString(@"File Access is Denied", @"File Access is Denied"),
                                     NSLocalizedString(@"OK", @"OK"),
                                     nil, nil);
    }
}


//-- dealloc
//
-(void) dealloc
{
	[_pasteboardWatcher release];
    [_acknowledgmentsWindowController release];
	[super dealloc];
}


//-- rescanDictionary
// 辞書を再走査する
- (void) rescanDictionary
{
/*
	[self selectDictionary:mCurrentDictionaryID];
    [_windowController selectBookAtIndex:mCurrentDictionaryID];
*/
}


//-- clearAllDictionaries
// すべての辞書を解放する
- (void) clearAllDictionaries
{
	/*
	//NSEnumerator *e;
	//EBook *obj;
	
    // 現在選択している辞書の保存
    [mCurrentDictionaryName release];
    mCurrentDictionaryName = [[mBinder longEBookTitle] retain];
    
    // 辞書リストを開放する
    [_windowController cleanBookMatrix];
    [mEBookArray removeAllObjects];
	[mEBooks removeAllObjects];
    mBinder = nil;  
	 */
}


//--- applicationWillTerminate
// アプリケーション終了時に呼ばれる
- (void) applicationWillTerminate : (NSNotification *) aNotification
{
    // 開いていた辞書の保存
	DictionaryBinder* binder = [_windowController currentDictionaryBinder];
    if(binder){
        [[PreferenceModal sharedPreference] setValue:[binder title]
											  forKey:kCurrentDictionary];
	}
	// 辞書の順番の保存
	DictionaryBinderManager* bm = [DictionaryBinderManager sharedDictionaryBinderManager];
	[bm recalcBinderIndex];
	// 初期設定の保存
    [[PreferenceModal sharedPreference] savePreferencesToDefaults];
}



#pragma mark -

//-- rescanDictionary
// 辞書の再走査
- (IBAction)rescanDictionary:(id)sender
{
	[self rescanDictionary];
}




#pragma mark -
//-- windowController
// window controllerを返す
-(WindowController*) windowController
{
	return _windowController;
}


//-- setWindowController
// ウィンドウコントローラの設定
-(void) setWindowController:(WindowController*) controller
{
	if(controller != _windowController){
		[_windowController release];
		_windowController = [controller retain];
	}
}


//-- haveSearchMethodByTag
// seach methodを持っているかどうか
- (BOOL) haveSearchMethodByTag : (int) inTag
{
	//return [mBinder haveSearchMethod:[self methodByTag:inTag]];
	return NO;
}


//-- methodByTag
// tag 番号をmethod名に変更する
- (ESearchMethod) methodByTag : (int) inTag
{
	static const ESearchMethod sMethods[] =
		{ 0, kSearchMethodWord, kSearchMethodEndWord, kSearchMethodKeyword, kSearchMethodMulti};
    
	if(inTag > 0 && inTag < (sizeof(sMethods)/sizeof(ESearchMethod))){
		return sMethods[inTag];
	}else{
		return kSearchMethodWord;
	}
}


//-- selectDictionary
// 辞書の選択
- (void) selectDictionary : (int) inIndex
{
  /*  if(inIndex >= 0 && inIndex < [mEBooks count]){
		mBinder = [mEBooks objectAtIndex:inIndex];
		[_windowController setTitle:[mBinder longEBookTitle]];
		[self showCopyright];
	
		// 検索方法の初期化
		[_windowController changeSearchMethod:[mBinder defaultSearchMethod]];
		[_windowController rescanSearchMethod];
		
    } else {
        [_windowController setTitle:nil];
        [_windowController setContents:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
		mBinder = nil;
    }
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:kDictionaryChangedNotification object:self userInfo:nil];
*/
}


//-- dictionaryName
// 辞書の名前を返す
- (NSString*) dictionaryName
{
	return @"";
	//return [mBinder longEBookTitle];
}


//-- showCopyright
// 辞書の著作権表示を行う
- (void) showCopyright
{
	/*
    int page, offset;
    
	if([mBinder ebookType] == kEbEBook){
		if([[mBinder book] copyright:&page offset:&offset] == YES){
			[self showContent:EBMakeLocation([[mBinder book] ebookNumber], page, offset)];
		}
	}else{
		//[_windowController setContents:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
	}*/
}




#pragma mark -

//-- newSearch
// 新規検索語の入力
- (IBAction)newSearch:(id)sender
{
    [_windowController showFront];
    //[_windowController clearSearchWord];
    [_windowController moveFocusToSearchView];
}


//-- searchAndPasteWord
// 指定語で前方検索を行う
- (void) searchAndPasteWord:(NSString*) inWord
{
	if(_binderManager && inWord != nil){
		// 最初の1行だけを取り出す
		NSRange range = [inWord lineRangeForRange:NSMakeRange(0, 0)];
		NSString* searchString = [inWord substringWithRange:range];
		range.length--;
		if(range.length > 0){
			[_windowController changeSearchMethod:kSearchMethodWord];
			[_windowController searchWord:searchString max:[[PreferenceModal prefForKey:kSearchAllMax] intValue]];
			[_windowController setInputText:searchString];
		}
	}
}








#pragma mark -
#pragma mark FontTable
//--- showFontTable
// Font tableを表示する
- (IBAction) showFontTable : (id) sender
{
	if(!_fontPanelController){
		_fontPanelController = [[FontPanelController alloc] init];
		[_fontPanelController bind:EBFontPanelDictionaryIdentifier
						   toObject:self
						withKeyPath:@"windowController.currentDictionaryBinder"
							options:nil];
	}
    [_fontPanelController showFontPanel];
}



#pragma mark -
#pragma mark Menu
//-- validateMenuItem
// メニューの状態を返す
- (BOOL) validateMenuItem:(NSMenuItem*) menuItem
{
    return YES;
}


#pragma mark -

//-- print
- (IBAction) runPageLayout : (id)sender
{
    [_windowController runPageLayout];
}


- (IBAction) print : (id)sender
{
    [_windowController print];
}


//-- showAcknowledgments
- (IBAction)showAcknowledgments:(id)sender
{
    if(_acknowledgmentsWindowController == nil){
        _acknowledgmentsWindowController = [[AcknowledgmentsWindowController alloc] init];
    }
    [_acknowledgmentsWindowController showWindow];
}

#pragma mark Service Menu / Pasteboard
//-- doLookupService:userData:error
// サービスメニューへの対応
- (void) doLookupService : (NSPasteboard *) pboard
				userData : (NSString *)     userData
				   error : (NSString **)    error
{
    NSArray *types;
    NSString *lookupWord;
    
    [_windowController showFront];
    
    // check pboard type
    types = [pboard types];
    if([types containsObject:NSStringPboardType] == NO) {
        *error = @"Error: paste board doesn't contain NSStringPboardType";
        return;
    }
    
    // get paste board string
    lookupWord = [pboard stringForType:NSStringPboardType];
    if (lookupWord == nil || [lookupWord length] <=0) {
        *error = @"Error: paste board doesn't contain NSStringPboardType";
        return;
    }
	[NSApp activateIgnoringOtherApps:YES];
    [self searchAndPasteWord:lookupWord];
	[_windowController moveFocusToHeading];
}


//-- applicationDidBecomeActive
// applicationがアクティブになった時に呼び出される
-(void) applicationDidBecomeActive:(NSNotification *) notification
{
	if([[PreferenceModal prefForKey:kUsePasteboardSearch] boolValue] == YES){
		[self searchPasteboardString];
	}
}


//-- searchPasteboardString
// pasteboardの中身を検索する
-(void) searchPasteboardString
{
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	NSArray *acceptableType = [NSArray arrayWithObjects:NSStringPboardType, NSRTFPboardType, nil];
	NSString *type = [pboard availableTypeFromArray:acceptableType];
	if(type != nil) {
		NSString *pboardData = [pboard stringForType:type];
		[self searchAndPasteWord:pboardData];
		[_windowController moveFocusToHeading];
	}
}


#pragma mark Apple Event
//-- handleSearchEvent:withReplyEvent:
// 検索用Apple eventを受取った時に呼び出される
-(void) handleSearchEvent:(NSAppleEventDescriptor *)event 
		   withReplyEvent:(NSAppleEventDescriptor *)replyEvent 
{
	NSString* searchString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	DictionaryBinder* binder = [_windowController currentDictionaryBinder];
	NSArray* array = [binder search:searchString method:kSearchMethodWord max:2 paramator:nil];
	if([array count] > 0){
		int i = 0;
		NSURL* url;
		do {
			url = [[array objectAtIndex:i] anchor];
		} while (url == nil && [array count] > ++i);
		if(url){
			EBLocation location = [self locationFromURL:url];
			EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:location.ebook];
			if(eb){
				NSString* content = [eb htmlContentAt:location];
				NSAppleEventDescriptor* contentDesc = [NSAppleEventDescriptor descriptorWithString:content];
				[replyEvent setParamDescriptor:contentDesc forKeyword:keyDirectObject];
			}
		}else{
			NSAppleEventDescriptor* contentDesc = [NSAppleEventDescriptor descriptorWithString:@""];
			[replyEvent setParamDescriptor:contentDesc forKeyword:keyDirectObject];
		}
	}else{
		NSAppleEventDescriptor* contentDesc = [NSAppleEventDescriptor descriptorWithString:@""];
		[replyEvent setParamDescriptor:contentDesc forKeyword:keyDirectObject];
	}
} 


//-- handleListEvent:withReplyEvent:
// 辞書リスト表示用Apple eventを受取った時に呼び出される
-(void) handleListEvent:(NSAppleEventDescriptor *)event 
		   withReplyEvent:(NSAppleEventDescriptor *)replyEvent 
{
	DictionaryBinderManager* bm = [DictionaryBinderManager sharedDictionaryBinderManager];
	NSArray* binders = [bm valueForKeyPath:@"binders"];
	NSAppleEventDescriptor* binderDescs = [[[NSAppleEventDescriptor alloc] initListDescriptor] autorelease];
	
	for(DictionaryBinder* binder in binders){
		NSAppleEventDescriptor* profDesc = [[[NSAppleEventDescriptor alloc] initRecordDescriptor] autorelease];
		NSAppleEventDescriptor* tagDesc = [NSAppleEventDescriptor descriptorWithString:[binder tagName]];
		[profDesc setDescriptor:tagDesc forKeyword:'tag_'];
		NSAppleEventDescriptor* idDesc = [NSAppleEventDescriptor descriptorWithInt32:(SInt32)[binder binderId]];
		[profDesc setDescriptor:idDesc forKeyword:'id__'];
		[binderDescs insertDescriptor:profDesc atIndex:0];
	}
	
	[replyEvent setParamDescriptor:binderDescs forKeyword:keyDirectObject];
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

#pragma mark Mount/Unmount
//-- didMountUnmount
// ディスクが挿入/排出されたら呼び出される
- (void) didMountUnmount : (NSNotification*) inNote
{
    if(_hasVolumes || 
       [[PreferenceModal prefForKey:kDiminishRescan] boolValue] == NO){
        [self rescanDictionary];
    }
}


//-- willUnmount
// ディスクが排出される予定 (すべての辞書を解放する)
- (void) willUnmount : (NSNotification*) inNote
{
    if(_hasVolumes){
        [self clearAllDictionaries];        
    }
}



#pragma mark Preference Window
// showPreferencePanel
// 環境設定ウィンドウを表示する
-(IBAction) showPreferencePanel : (id) sender
{
	[[PreferenceWindowController sharedPrefenceWindowController] showPanel:self];
}


#pragma mark Binding
//-- observeValueForKeyPath:ofObject:change:context:
// 文字設定の変更を監視する
-(void) observeValueForKeyPath : (NSString *) keyPath
					  ofObject : (id) object
						change : (NSDictionary *) change
					   context : (void *) context
{	
	if(context == EBPasteboardSearchBindingsIdentifier){
		//[self setContentURL:_currentLocation appendHistory:NO];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}



@end
