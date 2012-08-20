//	EBookCommon.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <string.h>
#import <eb/error.h>
#import <eb/appendix.h>

#import "ELDefines.h"
#import "EBookCommon.h"

typedef struct _SHit {
	char*	heading;
	EB_Position	content;
} SHit;

const int MAX_HITS = 50;
//static int gEBookNumber = 1;

@implementation EBookCommon

//-- initalizeLibrary
// EBLibの初期化処理
+(void) initalizeLibrary : (BOOL) inInitalize
{
    static int initalized = 0;
	
    if(inInitalize){
		if (initalized == 0) { eb_initialize_library(); }
		initalized++;
    }else{
		initalized--;
		if (initalized == 0) { eb_finalize_library(); }
    }
}


//-- init
// 初期化
-(id) init
{
	[super init];
	[[self class] initalizeLibrary:YES];
	
	eb_initialize_book(&mBook);
    eb_initialize_appendix(&mAppendix);
	
    //eb_initialize_hookset(&mTextHookset);
    //eb_set_hooks(&mTextHookset, get_text_hook());
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[self closeBook];
	[[self class] initalizeLibrary:NO];
	[super dealloc];
}

//-- closeBook
// 本の解放
- (void) closeBook
{
	if(eb_is_bound(&mBook) != 0) {
		eb_finalize_book(&mBook);
    }
}

//-- bind
// ファイルを開く
-(BOOL) bind : (NSString*) inPath
{
	const char* path = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:inPath];
	if(path == NULL){
		return NO;
    }
    if(eb_bind(&mBook, path) != EB_SUCCESS){
		return NO;
    }
    if(eb_subbook_list(&mBook, mSubbook, &mSubbookNum) != EB_SUCCESS){
		return NO;
    }

    return YES;	
}


#pragma mark subbook
//-- selectSubbook
// subbookの選択
-(BOOL) selectSubbook : (int) inIndex
{
	if(eb_set_subbook(&mBook, mSubbook[inIndex]) != EB_SUCCESS){
		return NO;
	}
	if(eb_have_word_search(&mBook) != 1){
		eb_unset_subbook(&mBook);
		return NO;
    }
	mActiveSubbook = inIndex;
	return YES;
}


//-- subbookNum
// subbookの数を返す
-(int) subbookNum
{
	return mSubbookNum; 
}


//-- stringSubbookTitle
// タイトルを返す
-(NSString*) stringSubbookTitle
{
    char title[EB_MAX_TITLE_LENGTH + 1];
    
	if(eb_subbook_title2(&mBook, mSubbook[mActiveSubbook], title) == EB_SUCCESS){
		int length = strlen(title);
		NSData* tmp = [NSData dataWithBytes:title length:length];
		return [[[NSString alloc] initWithData:tmp encoding:NSJapaneseEUCStringEncoding] autorelease];
    }else{
		return nil;
    }
}


//-- directryName
// 辞書の識別名を返す
-(NSString*) directoryName
{
    char title[EB_MAX_DIRECTORY_NAME_LENGTH];
	
    if(eb_subbook_directory2(&mBook, mSubbook[mActiveSubbook], title) == EB_SUCCESS){
    	return [NSString stringWithCString:title];
    }
    return NULL;
}


//-- setTagName
// タグ名の設定
- (void) setTagName : (NSString*) inTagName
{
    if(inTagName != nil && ![inTagName isEqualToString:@""]){
		[mTagName release];
		mTagName = [[NSString alloc] initWithString:inTagName];
    }
}


//-- tagName
// タグ名を返す
- (NSString*) tagName
{
    return (mTagName != NULL) ? mTagName : [self stringSubbookTitle];
}

#pragma mark search

//-- search:
// 最大 maxの見出し語を検索する
-(NSString*) search:(NSString*) inWord
{
	NSMutableData* key = [NSMutableData dataWithData:[inWord dataUsingEncoding:NSJapaneseEUCStringEncoding]];
	[key appendBytes:"\0" length:1];
	const char* word = [key bytes];
	
	EB_Error_Code err = eb_search_word(&mBook, word);
	
	EB_Hit hits[1];
	int hitNum;
	if((err = eb_hit_list(&mBook, 1, hits, &hitNum)) != EB_SUCCESS){
		NSLog(@"eb_hit_list:%s", eb_error_message(err));
		return nil;
	}
	
	if(hitNum > 0){
		return [self readText:hits[0].text];
	}
	return nil;
}


//-- readText
// テキストを呼び出す
- (NSString*) readText:(EB_Position) inLocation
{
	return nil;
}


#pragma mark preference
//-- preferencePath
// 辞書毎の設定が保存されているパスを返す
-(NSString*) preferencePath
{
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* dict = [self directoryName];
	NSArray* array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	// pathの中で存在しないディレクトリは作る
	if([array count] == 1){
		NSString* path = [[array objectAtIndex:0] stringByAppendingPathComponent:@"eblp"];
		BOOL isDirectory;
		if([fm fileExistsAtPath:path isDirectory:&isDirectory] == NO){
			[fm createDirectoryAtPath:path attributes:NULL];
		}else if(isDirectory == NO){
			NSLog(@"path %@ already exists but not a directory", path);
			return nil;
		}
		return [path stringByAppendingPathComponent:dict];
	}
    return nil;	
}


//-- loadPreferenceFromPath
// 辞書毎の設定をファイルから読み込む
-(void) loadPreferenceFromPath:(NSString*) inPath
{
	NSString* path = inPath ? inPath : [self preferencePath];
	if(path == nil || [[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
		// package内の設定ファイルは…ない!
		path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/"]
						stringByAppendingPathComponent:[self directoryName]];
		if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
			//[self createFontTableAll];
		}
	}
	NSArray* pref = [NSArray arrayWithContentsOfFile:path];
	if([pref count] > 2){
		[self setTagName:[[pref objectAtIndex:2] objectForKey:kDictionaryTagName]];
	}
}


@end
