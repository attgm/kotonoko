//	ContentsView.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "ContentsController.h"
#import "ContentsView.h"
#import "PreferenceModal.h"

void* kLinkAttributesBindingIdentifier = (void*) @"linkAttribute";

@implementation ContentsView

//-- awakeFromNib
// 初期化ルーチン
- (void) awakeFromNib
{
    [self setAllowsUndo:NO];
    [self setEditable:NO];
    [self setSelectable:YES];
    [self setRichText:YES];
    [self setImportsGraphics:YES];
    [self setTextContainerInset:NSMakeSize(0.0f, 4.0f)];
	[self setDisplaysLinkToolTips:NO];
    
	[[PreferenceModal sharedPreference] addObserver:self
										 forKeyPath:kLinkColor
											options:NSKeyValueObservingOptionNew
											context:kLinkAttributesBindingIdentifier];
    [[PreferenceModal sharedPreference] addObserver:self
										 forKeyPath:kLinkUnderLine
											options:NSKeyValueObservingOptionNew
											context:kLinkAttributesBindingIdentifier];
	
	[self observeLinkAttributes];
}


//-- dealloc
// デストラクタ
- (void) dealloc
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:NSUnderlineStyleAttributeName];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:NSForegroundColorAttributeName];
	
	[super dealloc];
}


//-- finalize
// 後片付け
-(void) finalize
{
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:NSUnderlineStyleAttributeName];
	[[PreferenceModal sharedPreference] removeObserver:self forKeyPath:NSForegroundColorAttributeName];
	
	[super finalize];
}


#pragma mark Observer
//-- observeValueForKeyPath:ofObject:change:context:
//
- (void) observeValueForKeyPath : (NSString *) keyPath
					   ofObject : (id) object
						 change : (NSDictionary *) change
						context : (void *) context
{
	if(context == kLinkAttributesBindingIdentifier){
		[self observeLinkAttributes];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


//-- observeLinkAttributes
// linkの色を設定する
-(void) observeLinkAttributes
{
	BOOL hasUnderLine = [[PreferenceModal prefForKey:kLinkUnderLine] boolValue];
	
	[self setLinkTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:(hasUnderLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone)], NSUnderlineStyleAttributeName,
		[PreferenceModal colorForKey:kLinkColor], NSForegroundColorAttributeName,
		[NSCursor pointingHandCursor], NSCursorAttributeName,
		nil]];
	[self setNeedsDisplay:YES];
}



@end
