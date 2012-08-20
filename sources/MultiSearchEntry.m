//	MultiSearchEntry.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "MultiSearchViewController.h"
#import "MultiSearchEntry.h"

@implementation MultiSearchEntry

//-- init
// 初期化
-(id) init
{
	self = [super init];
	if(self){
        _view = nil;
        _candidateData = nil;
	}
    return self;
}


//-- initWithTitle
// 初期化
-(id) initWithTitle:(NSString*) title
		 candidates:(NSArray*) candidates
{
	self = [super init];
	if(self){
        _view = nil;
        _candidateData = nil;
        _title = [title copyWithZone:[self zone]];
        _candidates = [candidates retain];
	}
	return self;
}


//-- entryWithTitle:candidates:
// 
+(MultiSearchEntry*) entryWithTitle:(NSString*) title
						 candidates:(NSArray*) candidates
{
	return [[[MultiSearchEntry alloc] initWithTitle:title candidates:candidates] autorelease];
}


//--dealloc
// 後片付け
-(void) dealloc
{
	[_view removeFromSuperview];
	[_view release];
	
	[_title release];
	[_candidates release];
	
	[super dealloc];
}


#pragma mark view
//-- view
// 表示用のviewを返す
-(NSView*) view
{
	if(!_view){
		if (![NSBundle loadNibNamed:@"MultiSearchEntry" owner:self]){
			NSLog(@"Failed to load MultiSearchEntry.nib");
			NSBeep();
			return nil;
		}
		
		[_entryField setStringValue:_title];
		[self adjustCandidates];
	}
	return _view;
}


//-- adjustCandidates
// 候補メニューの作成
-(void) adjustCandidates
{
	if(_candidates){
		[_textField setEditable:NO];
		[_textField setSelectable:NO];
		NSMenu* menu = [self createCandidatesMenu];
		[[_candidatePopUp cell] setUsesItemFromMenu:NO];
		[_candidatePopUp setMenu:menu];
	}else{
		[_textField setEditable:YES];
		[_candidatePopUp setEnabled:NO];
	}
}


//-- createCandidatesMenu
// 候補メニューを作成する
-(NSMenu*) createCandidatesMenu
{
	NSMenu* menu = [self menuFromCandidates:_candidates];
	// セパレタ
	[menu insertItem:[NSMenuItem separatorItem] atIndex:0];
	//タイトルの生成
	NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"none", @"none")
												   action:@selector(selectCandidate:)
											keyEquivalent:@""] autorelease];
	[item setTarget:self];
	[menu insertItem:item atIndex:0];
	//タイトルの生成
	NSMenuItem* title = [[[NSMenuItem alloc] initWithTitle:@"title" action:nil keyEquivalent:@""] autorelease]; 
	[menu insertItem:title atIndex:0];
	
	return menu;
}



//-- menuFromCandidates
// NSMenuの作成
-(NSMenu*) menuFromCandidates:(NSArray*) candidates
{
	NSMenu* menu = [[[NSMenu alloc] init] autorelease];
	for(NSDictionary* candidate in candidates){
		NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:@""
													  action:@selector(selectCandidate:)
											   keyEquivalent:@""];
		[item setTarget:self];
		NSAttributedString* title = [candidate objectForKey:@"title"];
		[item setAttributedTitle:title];
		NSArray* submenu = [candidate objectForKey:@"submenu"];
		if(submenu){
			[item setSubmenu:[self menuFromCandidates:submenu]];
		}
		NSData* data = [candidate objectForKey:@"candidate"];
		if(data){
			[item setRepresentedObject:data];
		}
		[menu addItem:item];
		[item release];
	}
	return menu;
}



//-- selectCandidate
// candidateの選択
-(IBAction) selectCandidate:(id) sender
{
	if([sender isKindOfClass:[NSMenuItem class]]){
		NSMenuItem* item = (NSMenuItem*) sender;
	
		if([item representedObject]){
			[_textField setAttributedStringValue:[item attributedTitle]];
			_candidateData = [item representedObject];
		}else{
			[_textField setStringValue:@""];
			_candidateData = nil;
		}
		
		if(_controller){ 
			[_controller didEntriesChanged];
		}
	}
}



//-- editEntry
// entryの編集
-(IBAction) editEntry:(id) sender
{
	if(_controller){ 
		[_controller didEntriesChanged];
	}
}


//-- keyView
// tabで移動するviewを返す
-(NSView*) keyView
{
	return (_candidates != nil) ? nil : _textField;
}


#pragma mark Controller
//-- setController
// コントローラの設定
-(void) setController:(MultiSearchViewController*) controller
{
	_controller = controller;
}

#pragma mark Data
//-- entryString
// 表示用の文字列を返す
-(NSString*) entryString
{
	NSMutableString* string = [NSMutableString stringWithString:[_textField stringValue]];
	
	if([string length] > 0){
		NSString* attachment = [NSString stringWithFormat:@"%C", (unsigned short)NSAttachmentCharacter];
		NSRange range = NSMakeRange(0, [string length]);
		[string replaceOccurrencesOfString:attachment withString:@"?" options:0 range:range];
	}
	
	return string;
}


//-- entryData
// 検索用の文字列を返す
-(id) entryData
{
	return _candidateData ? _candidateData : [_textField stringValue];
}

@end
