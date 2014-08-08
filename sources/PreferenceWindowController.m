//	PreferenceWindowController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "PreferenceDefines.h"
#import "PreferenceModal.h"

//#import "DictionaryListItem.h"
#import "DictionaryBinderManager.h"
#import "DictionaryManager.h"
#import "PreferenceWindowController.h"
#import "DictionaryListItem.h"

#import "DictionayArrayController.h"
#import "EBookUtilities.h"


enum {
	kOpenFolder = 1,
    kOpenAppendix = 2
};



//-- addToolbarItem
// ツールバーのアイテムを追加するユーテリティ関数
static NSToolbarItem* addToolbarItem(NSMutableDictionary *inDict,
									 NSString *inIdentifier,
									 NSString *inLabel,
									 NSString *inPaletteLabel,
									 NSString *inToolTip,
									 id 	inTarget,
									 SEL 	inSettingSelector,
									 id 	inItemContent,
									 SEL 	inAction,
									 NSMenu   *inMenu)
{
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:inIdentifier] autorelease];
    
    [item setLabel:inLabel];
    [item setPaletteLabel:inPaletteLabel];
    [item setToolTip:inToolTip];
    [item setTarget:inTarget];
    
    [item performSelector:inSettingSelector withObject:inItemContent];
    [item setAction:inAction];
    
    if (inMenu != NULL) {
		NSMenuItem* menuItem=[[[NSMenuItem alloc] init] autorelease];
		[menuItem setSubmenu:inMenu];
		[menuItem setTitle:[inMenu title]];
		[item setMenuFormRepresentation:menuItem];
    }
    [inDict setObject:item forKey:inIdentifier];
	return item;
}


@implementation PreferenceWindowController


static PreferenceWindowController *sSharedInstance = nil;

//-- sharedPrefenceWindowController
// return shared pref window controller
+(PreferenceWindowController*) sharedPrefenceWindowController
{
    if(sSharedInstance == nil){
		sSharedInstance = [[PreferenceWindowController alloc] init];
    }
    return sSharedInstance;
}



//-- init
// initialize
- (id) init
{
    if (sSharedInstance) {
		[self dealloc];
    } else {
        self = [super initWithWindowNibName:@"Preferences" owner:self];
		_preferenceModal = [PreferenceModal sharedPreference];
        sSharedInstance = self;
        _initialized = NO;
    }
    return sSharedInstance;
}


//-- dealloc
//
-(void)dealloc {
    [_panelViews release];
    [_toolbarItems release];
	[super dealloc];
}


//-- finalize
//
-(void)finalize {
	[super finalize];
}


#pragma mark User Interface

//-- showPanel
// display preference panel
-(void) showPanel:(id) sender
{
	if (_initialized == NO) {
        [self loadWindow];
        
        [_preferenceWindow setExcludedFromWindowsMenu:YES];
		[_preferenceWindow setMenu:nil];
		[_preferenceWindow center];
		[self createToolbar];
		
		_panelViews = [[NSDictionary alloc] initWithObjectsAndKeys:
			_dictionaryPanel,	kTagEBook,
			_networkPanel,		kTagNetworkDictionary,
			_booksetPanel,		kTagBookSet,
			_tagPanel,			kTagQuickTab,
			_fontPanel,			kTagFontAndColor,
			_viewPanel,			kTagView,
			_etcPanel,			kTagEtc, nil ];
		_displayedPanel = _panelBase;
		[_panelBase retain];
		
		[self switchPrefPanelById:kTagEBook animate:YES];
		[[_preferenceWindow toolbar] setSelectedItemIdentifier:kTagEBook];
		[_preferenceWindow setShowsToolbarButton:NO];
		
		DictionaryBinderManager* binder = [DictionaryBinderManager sharedDictionaryBinderManager];
		[_quickTagController bind:@"contentArray" toObject:binder withKeyPath:@"binders" options:nil];
        
        _initialized = YES;
	}
	[_preferenceWindow makeKeyAndOrderFront:nil];
}


// NSWindow delegate
- (void) windowWillClose : (NSNotification *) aNote
{
    //[self commitDisplayedValues];
}


//-- windowWillResize:toSize:
// resize 不可の場合 resizeさせない
/*-(NSSize) windowWillResize:(NSWindow*) window toSize:(NSSize) size
{
    NSLog([window showsResizeIndicator] ? @"yes" : @"no");
	return [window showsResizeIndicator] ? size : [window frame].size;
}*/


//-- createToolBar
// tool barの生成
-(void) createToolbar
{
	[_toolbarItems release];
	_toolbarItems = [[NSMutableDictionary dictionary] retain];
	addToolbarItem(_toolbarItems, kTagEBook, @"EBook", @"EBook",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_ebook"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagNetworkDictionary, @"NetworkDictionary", @"NetworkDictionary",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_network"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagBookSet, @"BookSet", @"BookSet",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_bookset"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagQuickTab, @"QuickTab", @"QuickTag",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_tag"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagFontAndColor, @"Font", @"Font",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_font"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagView, @"View", @"View",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_view"],
				   @selector(switchPrefPanel:), NULL);
	addToolbarItem(_toolbarItems, kTagEtc, @"Etc", @"Etc",
				   NULL, self,
				   @selector(setImage:), [NSImage imageNamed:@"toolbar_etc"],
				   @selector(switchPrefPanel:), NULL);
	
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"PreferenceToolBar"] autorelease];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	
	[_preferenceWindow setToolbar:toolbar];
}




//-- switchPrefPanel
// PrefPanelの切り替え
-(IBAction) switchPrefPanel:(id) sender
{
	[self switchPrefPanelById:[sender itemIdentifier] animate:YES];
}


//-- switchPrefPanelById
// PrefPanelの切り替え
-(void) switchPrefPanelById:(NSString*) identifier
					animate:(BOOL) animate
{
	NSView* view = [_panelViews objectForKey:identifier];
	NSRect windowFrame = [_preferenceWindow frame];
	NSRect contentFrame = [_displayedPanel frame];
	NSRect newFrame = [view frame];
	CGFloat diff = newFrame.size.height - contentFrame.size.height;
	windowFrame.size.height += diff;
	windowFrame.origin.y -= diff;
	newFrame.origin = contentFrame.origin;
	newFrame.size.width = contentFrame.size.width;
	
    BOOL viewHeightSizable = (([view autoresizingMask] & NSViewHeightSizable) != 0);
	[view setFrame:newFrame];
	[_preferenceWindow setMinSize:NSMakeSize(420, 240)];
	[_preferenceWindow setMaxSize:NSMakeSize(FLT_MAX,FLT_MAX)];
	[[_preferenceWindow contentView] replaceSubview:_displayedPanel with:_panelBase];
	[_preferenceWindow setFrame:windowFrame display:YES animate:animate];
	[[_preferenceWindow contentView] replaceSubview:_panelBase with:view];
	_displayedPanel = view;
    
    NSUInteger styleMask = [_preferenceWindow styleMask];
    
    [_preferenceWindow setStyleMask:
     (viewHeightSizable ? (styleMask | NSResizableWindowMask) : (styleMask & ~NSResizableWindowMask))];
	//[_preferenceWindow setShowsResizeIndicator:viewHeightSizable];
	
    NSButton *zoomButton = [_preferenceWindow standardWindowButton:NSWindowZoomButton];
	[zoomButton setEnabled:viewHeightSizable];
}

#pragma mark Dictionary Array

//-- dictionaries
// 辞書を返す
-(DictionaryManager*) dictionaries
{
	return [DictionaryManager sharedDictionaryManager];
}


//-- addDictionary
// 辞書への追加
-(void) addDictionary:(NSString*) path
{
	NSMutableArray* dictionaries = [PreferenceModal prefForKey:kDirectoryPath];
	[dictionaries addObject:path];
    if(IsAppSandboxed()){
        NSError *error = nil;
        NSData *bookmarkData = [[NSURL fileURLWithPath:path]
                                bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
        [PreferenceModal setSecurityBookmark:bookmarkData forPath:path];
    }
    [[DictionaryManager sharedDictionaryManager] appendDirectory:path];
}

//-- selectFolder
// フォルダの選択
- (IBAction) selectFolder : (id) sender
{
    NSOpenPanel* op;
    NSString* prompt;
    
    prompt = [[NSBundle mainBundle] localizedStringForKey:@"Select" value:@"Select" table:nil];
    
    // フォルダを選択
    op = [NSOpenPanel openPanel];
    [op setPrompt:prompt];
    [op setCanChooseDirectories:YES];
    [op setCanChooseFiles:NO];
	
    [op beginSheetModalForWindow:_preferenceWindow
               completionHandler:^(NSInteger result){
                   if(result == NSModalResponseOK){
                       NSString* filename = [[op URL] path];
                       switch([sender tag]){
                           case kOpenFolder:
                               [self addDictionary:filename];
                               break;
                           case kOpenAppendix:
                               [self addAppendix:filename];
                               break;
                       }
                   }
               }];
};


//-- deleteFolder
// folderの削除
- (IBAction) deleteFolder : (id) sender
{
    NSEnumerator* e = [[_treeController selectedObjects] objectEnumerator];
	DictionaryListItem* obj;
	NSMutableArray* dictionaries = [PreferenceModal prefForKey:kDirectoryPath];
	while (obj = [e nextObject]){
		NSUInteger index = [[DictionaryManager sharedDictionaryManager] removeDirectory:obj];
		[dictionaries removeObjectAtIndex:index];
	}
	[_treeController setSelectionIndexPath:nil]; 
}




#pragma mark Appendix

//-- addAppendix
// appendixの追加
-(void) addAppendix:(NSString*) path
{
	NSEnumerator* e = [[_treeController selectedObjects] objectEnumerator];
	id obj;
	while (obj = [e nextObject]){
		[obj setValue:path forKey:@"appendix"];
	}
    
    if(IsAppSandboxed()){
        NSError *error = nil;
        NSData *bookmarkData = [[NSURL fileURLWithPath:path]
                                bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
        [PreferenceModal setSecurityBookmark:bookmarkData forPath:path];
    }
}

//-- deleteAppendix
// appendixの削除
-(IBAction) deleteAppendix:(id)sender
{
    NSEnumerator* e = [[_treeController selectedObjects] objectEnumerator];
	id obj;
	while (obj = [e nextObject]){
		[obj setValue:nil forKey:@"appendix"];
	}
}


#pragma mark deletage : NSToolbar

//-- toolbarDefaultItemIdentifiers
// 初期toolbarの内容を返す
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:kTagEBook, kTagNetworkDictionary, kTagBookSet, kTagQuickTab, kTagFontAndColor, kTagView, kTagEtc, nil];
}


//-- toolbarSelectableItemIdentifiers
//
- (NSArray*) toolbarSelectableItemIdentifiers:(NSToolbar*) toolbar
{
	return  [NSArray arrayWithObjects:kTagEBook, kTagNetworkDictionary, kTagBookSet, kTagQuickTab, kTagFontAndColor, kTagView, kTagEtc, nil];}


//-- toolbarAllowedItemIdentifiers
// 設定可能なtoolbarの選択肢を返す
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:kTagEBook, kTagNetworkDictionary, kTagBookSet, kTagQuickTab, kTagFontAndColor, kTagView, kTagEtc, nil];
}



//-- toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar
// toolbarのエントリを返す
- (NSToolbarItem *)     toolbar : (NSToolbar *) toolbar
          itemForItemIdentifier : (NSString *) itemIdentifier
      willBeInsertedIntoToolbar : (BOOL) flag
{
    NSToolbarItem *newItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    NSToolbarItem *item=[_toolbarItems objectForKey:itemIdentifier];
    
	
    [newItem setLabel:NSLocalizedStringFromTable([item label], @"PreferenceToolbar", nil)];
    [newItem setPaletteLabel:NSLocalizedStringFromTable([item paletteLabel], @"PreferenceToolbar", nil)];
    if ([item view] != NULL){
		[newItem setView:[item view]];
    } else {
		[newItem setImage:[item image]];
    }
    [newItem setToolTip:[item toolTip]];
    [newItem setTarget:[item target]];
    [newItem setAction:[item action]];
    [newItem setMenuFormRepresentation:[item menuFormRepresentation]];
    
    if ([newItem view]!=NULL) {
		[newItem setMinSize:[[item view] bounds].size];
		[newItem setMaxSize:[[item view] bounds].size];
    }
    return newItem;
}

@end
