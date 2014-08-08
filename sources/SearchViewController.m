//	SearchViewController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import "HistoryDataSource.h"
#import "EBookController.h"
#import "SearchViewController.h"
#import "WindowController.h"
#import "PreferenceModal.h"

@implementation SearchViewController

//-- init
// 初期化
- (id) initWithWindowController:(WindowController*) inWindowController
{
    self = [super initWithNibName:@"SearchView" bundle:nil];
    if(self){
  		_windowController = inWindowController;
    }    
    return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[super dealloc];
}



#pragma mark Action
//-- switchSearchMethod
// 検索メソッドの変更
- (IBAction)switchSearchMethod:(id)sender
{
	[_windowController changeSearchMethod:(ESearchMethod)[sender selectedTag]];
	if([sender selectedTag] == kSearchMethodWord 
	   || [sender selectedTag] == kSearchMethodEndWord
	   || [sender selectedTag] == kSearchMethodKeyword){
		[self searchWordAll:self];
	}else{
		[_inputTextField setStringValue:@""];
	}
}


//-- searchWordAll
//　全部の検索結果の表示 (Enter/検索ボタンを押した時)
- (IBAction) searchWordAll:(id)sender
{
	// 検索
	_resultsMax = [[PreferenceModal prefForKey:kSearchAllMax] intValue];
    [_windowController searchWord:[_inputTextField stringValue] max:_resultsMax];
	// focusの移動
	[_windowController moveFocusToHeading];
}


#pragma mark User Interface
//-- selectSearchMethodWithTag
// method popup の変更
- (void) selectSearchMethodWithTag:(NSInteger) tag
{
    [_methodPopup selectItemWithTag:tag];
}


//-- firstController
// 入力部分を返す
- (NSView*) firstController
{
    return _inputTextField;
}


//-- setNextKeyView
// tab chainの設定
-(void) setNextKeyView:(NSView*) view
{
	[_inputTextField setNextKeyView:view];
}


//-- inputField
// 入力部分を返す
- (NSTextField*) inputField
{
    return _inputTextField;
}


//-- moveFocus
// focusをtext fieldに移動させる
- (void) moveFocus
{
    NSWindow* window = [self.view window];
    if(window){
        [window makeFirstResponder:_inputTextField];
    }
}


//-- clearSearchWord
// 検索語をクリアする
- (void) clearSearchWord
{
	[_inputTextField setStringValue:@""];
}


//-- setEnabled
// 検索語入力可能かどうかの判断
-(void) setEnabled:(BOOL) enable
{
	[_inputTextField setEnabled:enable];
}


#pragma mark Search Method
//-- rescanSearchMethods
// search method popupを再走査する
- (void) setSearchMethods:(NSArray*) searchMethods
{
	[_methodPopup removeAllItems];
	
    NSEnumerator* it = [searchMethods objectEnumerator];
    id obj;
    
    while ((obj = [it nextObject])){
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


//-- research
// もう一度検索を行う (researchだと研究になるよなぁ:p)
-(void) research
{
	[_windowController searchWord:[_inputTextField stringValue] max:_resultsMax];
}


#pragma mark Delegate:TextField
//-- controlTextDidEndEditing
// 入力が完了した時に呼ばれる
- (void) controlTextDidEndEditing:(NSNotification *) aNotification;
{
    // 履歴への追加
	if([_inputTextField stringValue] && [[_inputTextField stringValue] length] > 0){
		[_inputTextField reloadData];	
		[_history addHistory:[_inputTextField stringValue]];
	}
}


//-- textView:observeKeyDownEvent:
// キーが押されたイベントを受取って検索を行う
-(void) textView:(NSTextView*)textview observeKeyDownEvent:(NSEvent*)event
{
	_resultsMax = 0;
	[_windowController searchWord:[textview string] max:_resultsMax];	
}

@end
			