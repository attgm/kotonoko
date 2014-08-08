//	MultiSearchViewController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "PreferenceModal.h"
#import "EBookController.h"
#import "WindowController.h"
#import "MultiSearchViewController.h"
#import "MultiSearchEntry.h"
#import "DictionaryBinder.h"

static NSData* kNullString = NULL;
const NSInteger EBLayoutMargin = 20;


@implementation MultiSearchViewController

//-- init
// 初期化
- (id) initWithWindowController:(WindowController*) inWindowController
{
    self = [super initWithNibName:@"MultiSearchView" bundle:nil];
    
    if(self){
        _windowController = inWindowController;
		_entriesArray = [[NSMutableArray alloc] init];
        [self createSearchView];
    
        if(!kNullString){
            kNullString = [[NSData alloc] initWithBytes:"\0" length:1];
        }
    }
    return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_entriesArray release];
	[super dealloc];
}


//-- createSearchView
// nib から search viewを生成する
- (void) createSearchView
{
    [self loadView];
}


//-- view
// search viewを返す
- (NSView*) view
{
    return _searchFieldView;
}


//-- firstController
// 最初のControllerを表示
- (NSView*) firstController
{
	return _firstKeyView;
}


//-- moveFocus
// focusを移動
- (void) moveFocus
{
    NSWindow* window = [_searchView window];
    if(window){
	   [window makeFirstResponder:[self firstController]];
    }
}


#pragma mark -

#pragma mark Action
//-- switchSearchMethod
// 検索メソッドの変更
- (IBAction)switchSearchMethod:(id)sender
{
	[_windowController changeSearchMethod:(ESearchMethod)[sender selectedTag]];
	//[self searchWordAll:self];
}


//-- searchWordAll
//　全部の検索結果の表示 (Enter/検索ボタンを押した時)
- (IBAction)searchWordAll:(id)sender
{
	// 検索
	NSInteger resultsMax = [[PreferenceModal prefForKey:kSearchAllMax] intValue];
	[_windowController setContentsViewToDictionaryContents];
	[_disclosureButton setState:NSOffState];
    [_windowController searchEntries:[self entries] max:resultsMax];
	// focusの移動
	[_windowController moveFocusToHeading];
}


//-- discloseSearchEntry
// search entryを展開する
-(IBAction) discloseSearchEntry:(id) sender
{
	NSInteger state = [_disclosureButton state];
	if(state == NSOnState){
		[self setContentsViewToSearchEntriesView];
		[self moveFocus];
	}else{
		[_windowController setContentsViewToDictionaryContents];
		[_windowController moveFocusToHeading];
	}	
}


//-- setContentsViewToSearchEntriesView
// 検索エントリを表示させる
-(void) setContentsViewToSearchEntriesView
{
	[_windowController setContentsView:_searchView];
	[_disclosureButton setState:NSOnState];
}


#pragma mark Search Method
//-- setSearchMethods
// search method を設定する
- (void) setSearchMethods:(NSArray*) searchMethods
{
	[_methodPopup removeAllItems];
	
    NSEnumerator* it = [searchMethods objectEnumerator];
    id obj;
    
    while (obj = [it nextObject]){
		NSString* title = [obj objectForKey:@"title"];
		if([title isEqualToString:@"-"]){
			[[_methodPopup menu] addItem:[NSMenuItem separatorItem]];
		}else{
			NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
			[item setTitle:NSLocalizedString(title, title)];
			[item setTag:[[obj objectForKey:@"tag"] intValue]];
			[[_methodPopup menu] addItem:item];
		}
    }
}



//-- selectSearchMethodWithTag
// method popup の変更
- (void) selectSearchMethodWithTag:(NSInteger) tag
{
    [_methodPopup selectItemWithTag:tag];
	[self setSearchEntriesAtIndex:(tag - kSearchMethodMulti)];
}



#pragma mark -
#pragma mark Search Entries
//-- setSearchEntriesAtIndex
// entryを設定する
-(void) setSearchEntriesAtIndex:(NSInteger) index
{
	DictionaryBinder* binder = [_windowController currentDictionaryBinder];
	[_entriesArray removeAllObjects];
	[_tokenTextField setStringValue:@""];
	if([binder isKindOfClass:[SingleBinder class]]){
		SingleBinder* singleBinder = (SingleBinder*)binder;
		NSArray* array = [singleBinder multiSearchEntries:index];
		NSInteger entry = 0;
		for(NSString* title in array){
			NSArray* candidates = [singleBinder multiSearchCandidates:index entry:entry++];
			MultiSearchEntry* entry = [MultiSearchEntry entryWithLabel:title candidates:candidates];
			[entry setController:self];
			[_entriesArray addObject:entry];
		}
		[self adjustEntriesView];
	}
}


//-- adjustEntriesView
// 検索エントリの追加
-(void) adjustEntriesView
{
	NSArray* colors = [NSColor controlAlternatingRowBackgroundColors];
	NSInteger index = 0;
	
	NSView* view = [[_entriesArray lastObject] view];
	NSRect frame = [view frame];
	NSInteger height = frame.size.height * [_entriesArray count];
	
	NSView* clipView = [_searchEntriesView contentView];
	
	NSRect scrollViewFrame = [_searchEntriesView frame];
	NSInteger border = scrollViewFrame.size.height - [clipView bounds].size.height;
	NSRect baseFrame = [[_searchEntriesView superview] frame];
	
	if((height + border) > (baseFrame.size.height - EBLayoutMargin*2)){ 
		scrollViewFrame.size.height = (baseFrame.size.height - EBLayoutMargin*2); // ウィンドウ内に収まらない時
	}else{
		scrollViewFrame.size.height = height + border;
	}
	scrollViewFrame.origin.y = baseFrame.size.height - EBLayoutMargin - scrollViewFrame.size.height;
	[_searchEntriesView setFrame:scrollViewFrame];
	
	NSView* documentView = [_searchEntriesView documentView];
	NSRect documentFrame = [documentView frame];
	
	documentFrame.size.width = [clipView bounds].size.width;
	documentFrame.size.height = height;
	documentFrame.origin = NSMakePoint(0,0);
	[documentView setFrame:documentFrame];
	
	frame.size.width = documentFrame.size.width;
	frame.origin = NSMakePoint(0, height);
	
	NSView* previousKeyView = nil;
	_firstKeyView = nil;
	for(MultiSearchEntry* entry in _entriesArray){
		frame.origin.y -= frame.size.height;
		NSView* entryView = [entry view];
		[entryView setFrame:frame];
		if([entryView isKindOfClass:[NSBox class]]){
			[(NSBox*)entryView setFillColor:[colors objectAtIndex:(index++ % [colors count])]];
		}
		[documentView addSubview:entryView];
		
		NSView* keyView = [entry keyView];
		if(keyView){
			if (previousKeyView) [previousKeyView setNextKeyView:keyView];
			previousKeyView = keyView;
			if(!_firstKeyView){
				_firstKeyView = keyView;
			}
		}
		if(_firstKeyView && previousKeyView && _firstKeyView != previousKeyView){
			[previousKeyView setNextKeyView:_firstKeyView];
		}
	}
}



//-- didEntriesChanged
// エントリが変更された時の処理
-(void) didEntriesChanged
{
	NSMutableArray* token = [NSMutableArray arrayWithCapacity:[_entriesArray count]];
							 
	for(MultiSearchEntry* entry in _entriesArray){
		NSString* string = [entry entryString];
		if(string && [string length] > 0){
			[token addObject:string];
		}
	}
	[_tokenTextField setObjectValue:token];
}



//-- entries
// 検索文字列の一覧
-(NSArray*) entries
{
	NSMutableArray* entries = [NSMutableArray arrayWithCapacity:[_entriesArray count]];
	
	for(MultiSearchEntry* entry in _entriesArray){
		id data = [entry entryData];
		[entries addObject:data];
	}
	return entries;
}




//-- searchEntriesView
// 検索文字列入力view返す
-(NSView*) searchEntriesView
{
	return _searchView;
}


//-- isShowedSearchEntriesView
// 検索文字列入力モードかどうか
-(BOOL) showSearchEntriesView
{
	return ([_windowController currentContentsView] == _searchView);
}


@end
