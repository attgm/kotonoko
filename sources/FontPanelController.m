//	FontPanelController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//
#import <objc/objc-runtime.h>

#import "ELDefines.h"
#import "EBook.h"
#import "EBookController.h"
#import "FontTableElement.h"
#import "FontPanelController.h"
#import "DictionaryBinderManager.h"
#import "DictionaryBinder.h"
#import "ACBindingItem.h"

NSString* const EBFontPanelDictionaryIdentifier = @"FontPanelDitionary";

@implementation FontPanelController 

//-- init
// 初期化
- (id) init
{
	self = [super initWithWindowNibName:@"FontPanel" owner:self];
	if(self){
        [self setFontsArray:nil];
        _fontKind = kFontTypeNarrow;
        _selectedFonts = [[NSIndexSet alloc] init];
        [self.window setMenu:nil];
        [self.window center];
	}
    return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[self unbind:EBFontPanelDictionaryIdentifier];
	
}




#pragma mark -

//--- showFontPanel
// Font Panelを表示する
- (void) showFontPanel
{
    [self.window makeKeyAndOrderFront:nil];
    [self observeDictionary:nil];
}



#pragma mark Interface
//-- fontKind
// フォント種別
-(int) fontKind
{
	return _fontKind;
}



//-- setFontKind
// フォント種別の設定
-(void) setFontKind:(int) kind
{
	if(_fontKind != kind){
		_fontKind = kind;
		[self observeDictionary:nil];
	}
}


//-- currentElement
// 現在選択しているelementを返す
-(FontTableElement*) currentElement
{
	return _currentElement;
}


//-- setCurrentElement
// 現在選択しているelementを変更する
-(void) setCurrentElement:(FontTableElement*) element
{
	_currentElement = element;
}


//-- fonts
// 外字一覧を返す
-(NSArray*) fontsArray
{
	return _fontsArray;
}


//-- setFonts
// 外字一覧を設定する
-(void) setFontsArray:(NSArray*) fonts
{
	_fontsArray = fonts;
}


#pragma mark Actions


#pragma mark Export
//-- exportFontTable
// font tableを外部ファイルに出力する
- (IBAction) exportFontTable : (id) sender
{
	if(_currentBinder == kFalseBinderId){ return; }
	DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:_currentBinder];
	if(!binder || ![binder isKindOfClass:[SingleBinder class]]){ return; };
	
    _panel = [NSSavePanel savePanel];
	
    [_panel setCanSelectHiddenExtension:YES];
    [_panel setAllowedFileTypes:[NSArray arrayWithObject:kPlistFileType]];
	[_formatPopup selectItemWithTag:kFileFormat2x];
	[_panel setAccessoryView:_accessoryView];
    [_panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [_panel setNameFieldStringValue:[NSString stringWithFormat:@"%@.%@", [binder tagName], kPlistFileType]];
    [_panel beginSheetModalForWindow:self.window
                   completionHandler:^(NSInteger result){
                       if(_currentBinder == kFalseBinderId){ return; }
                       DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:_currentBinder];
                       if(!binder || ![binder isKindOfClass:[SingleBinder class]]){ return; };
                           
                       if (result == NSModalResponseOK) {
                           NSString* filePath = [[_panel URL] path];
                           BOOL hideExtension = [_panel isExtensionHidden];
                           [(SingleBinder*)binder savePrefToFile:filePath format:[_formatPopup selectedTag]];
                               
                           // 拡張子を隠す場合は隠す
                           NSFileManager* fm = [NSFileManager defaultManager];
                           NSError* error;
                           [fm setAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:hideExtension]
                                                                         forKey:NSFileExtensionHidden]
                                ofItemAtPath:filePath
                                       error:&error];
                       }
                   }];
}


//-- changeExportFileFormat
// 出力ファイルのフォーマットが変更された時の処理
-(IBAction) changeExportFileFormat:(id) sender
{
	NSInteger tag = [[sender selectedItem] tag];
	if(tag == kFileFormat1x){
		[_panel setAllowedFileTypes:[NSArray arrayWithObject:kGaijiFileType]];
	}else{
		[_panel setAllowedFileTypes:[NSArray arrayWithObject:kPlistFileType]];
	}
}





#pragma mark Import
//-- importFontTable
// font tableを外部ファイルから読み込む
- (IBAction) importFontTable : (id) sender
{
	if(_currentBinder == kFalseBinderId){ return; }
	DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:_currentBinder];
	if(!binder || ![binder isKindOfClass:[SingleBinder class]]){ return; };
	
    NSOpenPanel  *op = [NSOpenPanel openPanel];
    
    [op setCanChooseDirectories:NO];
    [op setCanChooseFiles:YES];
    [op setAllowsMultipleSelection:NO];
    [op setPrompt:NSLocalizedString(@"Select", @"Select")];
	
    [op setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [op beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(_currentBinder == kFalseBinderId){ return; }
        DictionaryBinder* binder = [DictionaryBinderManager findDictionaryBinderForId:_currentBinder];
        if(!binder || ![binder isKindOfClass:[SingleBinder class]]){ return; };
        
        if ( result == NSModalResponseOK ) {
            NSString* filePath = [[op URL] path];
            [(SingleBinder*)binder loadPrefFromFile:filePath];
            [self observeDictionary:nil];
        }

    }];
}


//-- importFontConfirmation:returnCode:contextIndo
// 不正な外部ファイルであった時の処理
- (void) importFontConfirmation : (NSPanel *) inSheet
					 returnCode : (int) inReturnCode
					contextInfo : (NSArray *) inContextInfo
{
    if (inReturnCode == NSAlertFirstButtonReturn) {
		//[mCurrentEBook loadPrefFromArray:inContextInfo];
		[self observeDictionary:nil];
    }
}



#pragma mark Bindings
//-- bindingItem
// bindingを管理するクラスを返す
-(ACBindingItem*) bindingItem
{
	if(!_bindingItem){
		_bindingItem = [[ACBindingItem alloc] initWithSelector:@selector(observeDictionary:)
													valueClass:[DictionaryBinder class]
													identifier:(const void*)EBFontPanelDictionaryIdentifier];
	}
	return _bindingItem;
}


//-- valueClassForBinding:
//
- (Class) valueClassForBinding:(NSString *)binding {
	
	if([binding isEqualToString:EBFontPanelDictionaryIdentifier]){
		return [[self bindingItem] valueClass];
	}else{
		return [super valueClassForBinding:binding];
	}
}



//-- bind:toObject:withKeyPath:options:
//
- (void)		bind:(NSString *) binding
			toObject:(id) observableObject
			withKeyPath:(NSString *) keyPath
				options:(NSDictionary *) options
{
	if([binding isEqualToString:EBFontPanelDictionaryIdentifier]){
		ACBindingItem* item = [self bindingItem];
		[item setObservedController:observableObject];
		[item setObservedKeyPath:keyPath];
		[item setTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:[item identifier]];
        if([self respondsToSelector:[item selector]]){
            objc_msgSend(self, [item selector], item);
        }
	}else{
		[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
	}
}    



//-- observeValueForKeyPath:ofObject:change:context:
//
- (void) observeValueForKeyPath : (NSString *) keyPath
					   ofObject : (id) object
						 change : (NSDictionary *) change
						context : (void *) context
{
	if(context == (__bridge void *)(EBFontPanelDictionaryIdentifier)){
		ACBindingItem* item = [self bindingItem];
        if([self respondsToSelector:[item selector]]){
            objc_msgSend(self, [item selector], item);
        }
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


//-- infoForBinding
//
- (NSDictionary*) infoForBinding : (NSString *) binding
{
	if(binding == EBFontPanelDictionaryIdentifier){
		ACBindingItem* item = [self bindingItem];
		return [item infoForBinding];
	}else{
		return [super infoForBinding:binding];
	}
}



//-- unbind
// 
- (void) unbind : (NSString *) binding
{
	if(binding == EBFontPanelDictionaryIdentifier){
		ACBindingItem* item = [self bindingItem];
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}else{
		[super unbind:binding];
	}
}


#pragma mark Observer

//-- observeDictionary
// 辞書の変更を認識する
-(void) observeDictionary:(ACBindingItem*) item
{
	if (self.window && [self.window isVisible]) {
		if(!item){
			item = [self bindingItem];
		}
		DictionaryBinder* binder = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	
		if(binder && [binder isKindOfClass:[DictionaryBinder class]]){
			[self.window setTitle:[NSString stringWithFormat:NSLocalizedString(@"GAIJI", @"GAIJI"), [binder title]]];
			if([binder isKindOfClass:[SingleBinder class]]){
				[self setFontsArray:[(SingleBinder*)binder fontTable:_fontKind]];
				_currentBinder = [binder binderId];
			}else{
				[self setFontsArray:nil];
				_currentBinder = -1;
			}
			_currentElement = nil;
		}
	}
}


@end
