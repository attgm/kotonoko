//	EBStyleSheet.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "PreferenceModal.h"
#import "PreferenceUtilities.h"

#import "EBStyleSheet.h"

static EBStyleSheet* sSharedEBStyleSheet = nil;
static NSString* const kStyleSheetSheme = @"style:default";
static NSString* const kWebKitIdentifier = @"KotonokoViewer";
static void* const kStyleSheetBindingsIdentifier = (void*) @"styleSheet";


@implementation EBStyleSheet

//-- sharedStyleSheet
// EBookビューワ用スタイルシートの生成
+(EBStyleSheet*) sharedStyleSheet
{
	if(!sSharedEBStyleSheet){
		sSharedEBStyleSheet = [[EBStyleSheet alloc] init];
	}
	return sSharedEBStyleSheet;
}


//-- init
// 初期化
-(id) init
{
	self = [super init];
	if(self){
        if(sSharedEBStyleSheet){
            [self release];
            return sSharedEBStyleSheet;
        }
        sSharedEBStyleSheet = self;
        
        [self registerStyleSheet];
        [self updateStyleSheet];
    }
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsFont];
	[super dealloc];
}



//-- finalize
// 後片付け
-(void) finalize
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:kContentsFont];
	[super finalize];
}


//-- registerStyleSheet
// スタイルシートを指定
-(void) registerStyleSheet
{
	_webPreferences = [[WebPreferences alloc] initWithIdentifier:kWebKitIdentifier];
	[[PreferenceModal sharedPreference] addObserver:self
										 forKeyPath:kContentsFont
											options:NSKeyValueObservingOptionNew
											context:(void*)kStyleSheetBindingsIdentifier];
}

//-- webPreferences
// web 初期設定を返す 
-(WebPreferences*) webPreferences
{
	return _webPreferences;
}


#pragma mark Binding
//-- updateStyleSheet
// style sheetの変更
-(void) updateStyleSheet
{
	//-- フォントの設定
	NSFont* font = [PreferenceModal fontForKey:kContentsFont];
	[_webPreferences setStandardFontFamily:[font familyName]];
	[_webPreferences setDefaultFontSize:[font pointSize]];
	
}


//-- observeValueForKeyPath:ofObject:change:context:
// 環境設定が変更された時に呼び出される
-(void) observeValueForKeyPath : (NSString *) keyPath
					  ofObject : (id) object
						change : (NSDictionary *) change
					   context : (void *) context
{	
	if(context == kStyleSheetBindingsIdentifier){
		[self updateStyleSheet];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


@end
