//	EBook.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "EBook.h"
#import <string.h>
#import <eb/font.h>
#import <eb/error.h>
#import <eb/binary.h>
// これはincludeしちゃいけない気もするけどなぁ
#import <eb/build-post.h> 
#import <stdio.h>

#import "DictionaryElement.h"
#import "FontTableElement.h"
#import "EBookContainer.h"
#import "EBookHookFunctions.h"
#import "CandidateContainer.h"
#import "EBookUtilities.h"

#import "LineTextAttachmentCell.h"

NSString* const EBContentsConinuity		= @"contentsConinuity";
NSString* const EBShowGaijiCode			= @"showGaijiCode";
NSString* const EBFontImageHeight		= @"fontImageHeight";
NSString* const EBSuperScriptAttributes = @"superSctiprAttributes";
NSString* const EBSubScriptAttributes	= @"subSctiprAttributes";
NSString* const EBKeywordAttributes		= @"keywordAttributes";
NSString* const EBGaijiAttributes		= @"gaijiAttributes";
NSString* const EBEmphasisAttributes	= @"emphasisAttributes";
NSString* const EBTextAttributes		= @"textAttributes";
NSString* const EBReferenceTextColor	= @"referenceTextColor";
NSString* const kUseAlternativeString	= @"useAlternativeString";
NSString* const kAlternativeString		= @"alternativeString";
NSString* const kNarrowFontTable		= @"narrowFonts";
NSString* const kWideFontTable			= @"wideFonts";
NSString* const EBTagAttributes			= @"tagAttributes";

typedef struct _SHit {
    char*	heading;
    EB_Position	content;
} SHit;

const NSUInteger MAX_HITS = 50;
const NSUInteger NUMBER_OF_WORDS = 5;

static NSUInteger gEBookNumber = 1;
static NSNumber *yes, *no;

@implementation EBook
@synthesize ebookNumber = _ebookNumber;

#pragma mark Initalize
//-- initalizeLibrary
// EBLibの初期化を行う(1度だけ実行)
+(void) initalizeLibrary : (BOOL) init
{
    static int sInitEBLibrary = 0;

    if(init){
		if(sInitEBLibrary == 0){
			eb_initialize_library();
		}
		sInitEBLibrary++;
    }else{
		sInitEBLibrary--;
		if(sInitEBLibrary == 0){
			eb_finalize_library();
		}
    }
}


//-- init
// 初期化
-(id) init
{
    self = [super init];
    if(self){
        [EBook initalizeLibrary:YES];

        eb_initialize_book(&_book);
        eb_initialize_appendix(&_appendix);

        eb_initialize_hookset(&_textHookset);
        eb_set_hooks(&_textHookset, get_attributedtext_hook());

        eb_initialize_hookset(&_headingHookset);
        eb_set_hooks(&_headingHookset, get_heading_hook());

        eb_initialize_hookset(&_candidatesHookset);
        eb_set_hooks(&_candidatesHookset, get_candidates_hook());

        eb_initialize_hookset(&_htmlHookset);
        eb_set_hooks(&_htmlHookset, get_html_hook());

        _ebookNumber = gEBookNumber++;
        _hasSerialContents = NO;
    }
    return self;
}


//-- dealloc
// 削除
-(void) dealloc
{
	[self closeBook];
    [EBook initalizeLibrary:NO];
	
	[_narrowFontDic release];
	[_wideFontDic release];
	[super dealloc];
};


//-- finaize
// 終了処理
-(void) finalize
{
	[self closeBook];
    [EBook initalizeLibrary:NO];
	[super finalize];
}


//-- bind:
// 辞書のバインド
-(BOOL) bind:(NSString*) inPath
{
    const char* path = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:inPath];

    if(path == NULL){
		return NO;
    }
    if(eb_bind(&_book, path) != EB_SUCCESS){
		return NO;
    }
    if(eb_subbook_list(&_book, _subbook, &_subbookNum) != EB_SUCCESS){
		return NO;
    }
    return YES;
}


//-- closeBook
// 本の解放
-(void) closeBook
{
    if(eb_is_bound(&_book) != 0){
		eb_finalize_book(&_book);
    }
}


//-- bindAppendix:subook
// appendixを関連づける
-(BOOL) bindAppendix : (NSString*) inPath
{
    int appendix;
    EB_Subbook_Code subbooks[EB_MAX_SUBBOOKS];
    EB_Error_Code err;
    
    const char* path = [[NSFileManager defaultManager] fileSystemRepresentationWithPath:inPath];
    if(path == NULL){
		return NO;
    }
    if((err = eb_bind_appendix(&_appendix, path)) != EB_SUCCESS){
		NSLog(@"eb_bind_appendix:%s", eb_error_message(err));
		return NO;
    }
    if((err = eb_appendix_subbook_list(&_appendix, subbooks, &appendix)) != EB_SUCCESS){
		NSLog(@"eb_appendix_subbook_list:%s", eb_error_message(err));
		return NO;
    }
    if((err = eb_set_appendix_subbook(&_appendix, subbooks[_activeSubbook])) != EB_SUCCESS){
		NSLog(@"eb_set_appendix_subbook:%s", eb_error_message(err));
		return NO;
    }
    return YES;
}



#pragma mark Subbook

//-- selectSubbook
// subbookの選択
-(BOOL) selectSubbook : (int) inIndex
{
    EB_Error_Code err;
    static ESearchMethod methods[] = { kSearchMethodWord, kSearchMethodEndWord, kSearchMethodKeyword,
								kSearchMethodMenu, kSearchMethodMulti };
	
    if((err = eb_set_subbook(&_book, _subbook[inIndex])) != EB_SUCCESS){
		NSLog(@"eb_set_subbook:%s", eb_error_message(err));
		return NO;
    }
	
	ESearchMethod defaultMethod = kSearchMethodNone;
	int i;
	for(i=0; i<sizeof(methods); i++){
		if([self haveSearchMethod:methods[i]]){
			defaultMethod = methods[i];
			break;
		}
	}
    if (defaultMethod == kSearchMethodNone) return NO;
	
    _activeSubbook = inIndex;
    if(eb_have_multi_search(&_book)){
		if (eb_multi_search_list(&_book, _multiCode, &_multiCodeNum) != EB_SUCCESS) {
			return NO;
		}
    }
    [self setFontSize];
    return YES;
}


//-- subbookNum
// 副本の数を返す
-(int) subbookNum
{
    return _subbookNum;
}


-(NSString*) stringSubbookTitle
{
    char title[EB_MAX_TITLE_LENGTH + 1];
    int length;
    NSData* tmp;
    
    if(eb_subbook_title2(&_book, _subbook[_activeSubbook], title) == EB_SUCCESS){
		length = strlen(title);
		tmp = [NSData dataWithBytes:title length:length];
		return [[[NSString alloc] initWithData:tmp encoding:NSJapaneseEUCStringEncoding] autorelease];
    }else{
		return NULL;
    }
}


-(void) setTagName : (NSString*) inTagName
{
    if(inTagName != nil && ![inTagName isEqualToString:@""]){
		[_tagName release];
		_tagName = [[NSString alloc] initWithString:inTagName];
    }
}


-(NSString*) tagName
{
    return (_tagName != NULL) ? _tagName : [self stringSubbookTitle];
}

#pragma mark Multi Search
//-- arrayMultiSearchTitle
// マルチサーチのタイトルを返す
- (NSArray*) arrayMultiSearchTitle
{
    char title[EB_MAX_MULTI_TITLE_LENGTH + 1];
    NSData* tmp;
    NSMutableArray* array;
    int length, i;
    EB_Error_Code err;
    
    if (_multiCodeNum == 0) return NULL;
    
    array = [NSMutableArray arrayWithCapacity:_multiCodeNum];
    
    for(i=0; i<_multiCodeNum; i++){
        if((err = eb_multi_title(&_book, _multiCode[i], title)) != EB_SUCCESS){
            NSLog(@"eb_multi_title:%s", eb_error_message(err));
            return NULL;
        }
        length = strlen(title);
        tmp = [NSData dataWithBytes:title length:length];
        [array addObject:
            [[[NSString alloc] initWithData:tmp encoding:NSJapaneseEUCStringEncoding] autorelease]];
    }
    return array;
}



//-- arrayMultiSearchEntry
// 複合検索のエントリ検索
-(NSArray*) arrayMultiSearchEntry : (int) inIndex
{
    char label[EB_MAX_MULTI_LABEL_LENGTH + 1];
    EB_Multi_Entry_Code code[EB_MAX_MULTI_ENTRIES];
    NSData* tmp;
    NSMutableArray* array;
    int length, counts, i;
    EB_Error_Code err;
    
    if(inIndex < 0 || inIndex >= _multiCodeNum){
		return NULL;
    }
    
    if ((err = eb_multi_entry_list(&_book, _multiCode[inIndex], code, &counts)) != EB_SUCCESS){
		NSLog(@"eb_multi_entry_list:%s", eb_error_message(err));
		return NULL;
    }

    array = [NSMutableArray arrayWithCapacity:counts];
    
    for (i=0; i<counts; i++){
		if (eb_multi_entry_label(&_book, _multiCode[inIndex], code[i], label) == EB_SUCCESS) {
			length = strlen(label);
			tmp = [NSData dataWithBytes:label length:length];
			[array addObject:
				[[[NSString alloc] initWithData:tmp encoding:NSJapaneseEUCStringEncoding] autorelease]];
		}
    }
    
    return array;
}


//-- arrayMultiSearchCandidates
// 複合検索の候補を取得する
-(NSArray*) arrayMultiSearchCandidates : (int) inIndex
									at : (int) inEntryID
{
    EB_Position position;
    EB_Error_Code err;
    EB_Multi_Entry_Code code[EB_MAX_MULTI_ENTRIES];
    int counts;
    
    if ((err = eb_multi_entry_list(&_book, _multiCode[inIndex], code, &counts)) != EB_SUCCESS){
		NSLog(@"eb_multi_entry_list:%s", eb_error_message(err));
		return NULL;
    }

    err = eb_multi_entry_candidates(&_book, _multiCode[inIndex], code[inEntryID], &position);
    if(err == EB_ERR_NO_CANDIDATES){
		return NULL; // 検索候補が存在しない
    }else if(err != EB_SUCCESS){
		NSLog(@"eb_multi_entry_candidates : %s", eb_error_message(err));
		return NULL;
    }
	
	return [self arrayMultiSearchCandidatesWithLocation:EBMakeLocation(_ebookNumber, position.page, position.offset)];
}


//-- arrayMultiSearchCandidatesWithLocation
// 複合検索の候補を返す
- (NSArray*) arrayMultiSearchCandidatesWithLocation:(EBLocation) inLocation
{
	static char buffer[EB_SIZE_PAGE];
    ssize_t length;
    EB_Position position;
    EB_Error_Code err;
    NSMutableArray* candidates = [NSMutableArray arrayWithCapacity:1];
	CandidateContainer* container = [[[CandidateContainer alloc] initWithEBook:self] autorelease];
	
	position.page = inLocation.page;
    position.offset = inLocation.offset;
    
    buffer[sizeof(buffer) - 1] = '\0';
    eb_seek_text(&_book, &position);

    do {
		err = eb_read_text(&_book, &_appendix, &_candidatesHookset, container, sizeof(buffer) - 1, buffer, &length);
    } while (err == EB_SUCCESS && length > 0);
    
    
	for(id candidate in [container candidates]){
		if([candidate isKindOfClass:[CandidateLeaf class]]){
			[candidates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   [candidate attributedString], @"title",
								   [candidate candidate], @"candidate", nil]];
		}else{
			NSArray* submenu = [self arrayMultiSearchCandidatesWithLocation:[(CandidateGroup*)candidate location]];
			[candidates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								   [candidate attributedString], @"title",
								   submenu, @"submenu", nil]];
		}
	}
	return candidates;
}


//-- search:method:max
// 最大inMaxHitsの見出し語を表示する
- (NSArray*) search : (NSString*) inWord
			 method : (ESearchMethod) inMethod
                max : (int) inMaxHits
		  paramator : (NSDictionary*) paramator
{
	NSData* eucWord = [inWord dataUsingEncoding:NSJapaneseEUCStringEncoding allowLossyConversion:NO];
    EB_Character_Code characterCode;
	if(eucWord == nil && eb_character_code(&_book, &characterCode) == EB_CHARCODE_JISX0208_GB2312){
		eucWord = [inWord dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_CN)
					   allowLossyConversion:NO];
	}
	if(eucWord == nil){
		eucWord = [inWord dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	}
	
	NSMutableData* key = [NSMutableData dataWithData:eucWord];
    [key appendBytes:"\0" length:1];
    const char* word = [key bytes];
	
	
	
    EB_Error_Code err;
    switch (inMethod) {
		case kSearchMethodWord:
			err = eb_search_word(&_book, word);
			break;
		case kSearchMethodEndWord:
			err = eb_search_endword(&_book, word);
			break;
		case kSearchMethodKeyword:
			err = [self searchKeyword:[key mutableBytes] length:[key length]];
			break;
		default:
			err = EB_ERR_NO_SUCH_SEARCH;
			break;
	}
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:MAX_HITS];
    if(err != EB_SUCCESS){
		return array;
    }
    
	NSAttributedString* tagName = [[[NSAttributedString alloc] initWithString:[self tagName]
																   attributes:[paramator objectForKey:EBTagAttributes]] autorelease];
    [array addObject:[DictionaryElement elementWithHeading:tagName
													anchor:EBMakeLocation(_ebookNumber, -1, 0)]];
	//NSDictionary* parametor = [self headingParamator];
	int hitNum;
	EB_Hit hits[MAX_HITS];
	do {
		if((err = eb_hit_list(&_book, MAX_HITS, hits, &hitNum)) != EB_SUCCESS){
			NSLog(@"eb_hit_list:%s", eb_error_message(err));
			return array;
		}
	
		if (hitNum == 0) break;
		int i;
		for(i=0; i<hitNum && [array count] < inMaxHits; i++){
			EBLocation location = EBMakeLocation(_ebookNumber, hits[i].text.page, hits[i].text.offset);
			if([self isDuplicate:location at:array] == NO){
				EB_Position* position = &(hits[i].heading);
				[array addObject:[DictionaryElement elementWithHeading:[self stringHeading:position paramator:paramator]
																anchor:location]];
			}
		}
	} while(([array count] < inMaxHits) && (hitNum > 0));
    
	return array;
}





//-- searchKeyword:length:
// キーワード検索を行う
- (EB_Error_Code) searchKeyword : (char*) inWord
                         length : (int) inLength
{
    char* keywords[inLength/2 + 2]; // keywordは最低1文字なので length/2+1個. +1はNULLの分
    char* p = inWord;
    int index = 0;
    BOOL key = NO;
    
    while(*p != '\0'){
	if(*p == ' '){
	    *p = '\0';
	    key = NO;
	}else{
	    if(key == NO){
		keywords[index++] = p;
		key = YES;
	    }
	}
	p++;
    }
    keywords[index] = NULL;

    return eb_search_keyword(&_book, (const char* const*)keywords);
}


//-- multiSearch:index:max:paramator
// 複合検索の実行
-(NSArray*) multiSearch:(NSArray*) searchEntries
				  index:(NSInteger) index
					max:(int) maxHits
			  paramator:(NSDictionary*) paramator
{
	EB_Error_Code err;
    const char* entries[EB_MAX_MULTI_ENTRIES + 1];
    
	NSInteger i = 0;
	for(id obj in searchEntries){
		if([obj isKindOfClass:[NSData class]]){
			entries[i] = [obj bytes];
		}else if([obj isKindOfClass:[NSString class]]){
			entries[i] = [obj cStringUsingEncoding:NSJapaneseEUCStringEncoding];
		}else{
			entries[i] = "\0";
		}
		i++;
	}
    entries[i] = NULL;

    if((err = eb_search_multi(&_book, _multiCode[index], entries)) != EB_SUCCESS){
        NSLog(@"eb_search_multi:%s", eb_error_message(err));
        return NULL;
    }
    
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:MAX_HITS];
    if(err != EB_SUCCESS){
		return array;
    }
    
	NSAttributedString* tagName = [[[NSAttributedString alloc] initWithString:[self tagName]
																   attributes:[paramator objectForKey:EBTagAttributes]] autorelease];
    [array addObject:[DictionaryElement elementWithHeading:tagName
													anchor:EBMakeLocation(_ebookNumber, -1, 0)]];
	int hitNum;
    EB_Hit hits[MAX_HITS];
	do {
		if((err = eb_hit_list(&_book, MAX_HITS, hits, &hitNum)) != EB_SUCCESS){
			NSLog(@"eb_hit_list:%s", eb_error_message(err));
			return array;
		}
    
		if (hitNum == 0) break;
		int i;
		for(i=0; i<hitNum && [array count] < maxHits; i++){
			EBLocation location = EBMakeLocation(_ebookNumber, hits[i].text.page, hits[i].text.offset);
			if([self isDuplicate:location at:array] == NO){
				EB_Position* position = &(hits[i].heading);
				[array addObject:[DictionaryElement elementWithHeading:[self stringHeading:position paramator:paramator]
																anchor:location]];
			}
		}
    } while(([array count] < maxHits) && (hitNum > 0));
    
    return array;
}


//-- isDuplicate:at:
// 検索語の重複チェック
-(BOOL) isDuplicate:(EBLocation) location
				 at:(NSArray*) array
{
	NSString* locationString = [DictionaryElement locationToURLString:location];
	
	for(DictionaryElement* it in array){
		NSString* string = [it URLString];
		if(string && [string isEqualToString:locationString]){
			return YES;
		}
	}
	return NO;
}


- (NSString*) directoryName
{
    char title[EB_MAX_DIRECTORY_NAME_LENGTH + 1];

    if(eb_subbook_directory2(&_book, _subbook[_activeSubbook], title) == EB_SUCCESS){
    	return [NSString stringWithCString:title encoding:NSASCIIStringEncoding];
    }
    return NULL;
}

#pragma mark menu
//-- haveMenu
// メニューを持っているかどうか
-(BOOL) haveMenu
{
	return (eb_have_menu(&_book) == 1) ? YES : NO;
}


//-- menuWithParamator
// メニューを表示させる
-(NSAttributedString*) menuWithParamator:(NSDictionary*) paramator
{
	EB_Position pos;
	if (eb_menu(&_book, &pos) != EB_SUCCESS) {
		return nil;
    }
	
	EBLocation location = EBMakeLocation(_ebookNumber, pos.page, pos.offset);
	
	return [self contentAt:location paramator:paramator];
}


//-- copyright
// コピーライト文字列を返す
-(NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator
{
	EB_Position pos;
	
	if (!eb_have_copyright(&_book)) {
		return nil;
    }
    if (eb_copyright(&_book, &pos) != EB_SUCCESS) {
		return nil;
    }
    
	EBLocation location = EBMakeLocation(_ebookNumber, pos.page, pos.offset);
	
	return [self contentAt:location paramator:paramator];
}


//-- strigHeading
// heading stringを取得する
- (NSAttributedString*) stringHeading:(EB_Position*) inPosition
							paramator:(NSDictionary*) paramator
{
	static char buffer[64];
    ssize_t length;
    
    buffer[sizeof(buffer) - 1] = '\0';
    EBookContainer* container = [[[EBookContainer alloc] initWithEBook:self] autorelease];
    [container setParamator:paramator];
	[container setAttribute:[paramator objectForKey:EBTextAttributes]];

    eb_seek_text(&_book, inPosition);
    eb_read_heading(&_book, &_appendix, &_headingHookset, container, sizeof(buffer) - 1, buffer, &length);
    return [container attributedString];
}


#pragma mark Read Text
//-- contentAt:paramator:
// テキストを位置指定で呼び出す
- (NSAttributedString*) contentAt:(EBLocation) location
						paramator:(NSDictionary*) param
{
    EB_Position position;
	position.page = location.page;
    position.offset = location.offset;
	
	eb_seek_text(&_book, &position);
    NSAttributedString* string = [self readTextWithParamator:param]; 
	return string;
}


//-- htmlContentAt:
// テキストを位置指定で呼び出す
- (NSString*) htmlContentAt:(EBLocation) location
{
    EB_Position position;
	position.page = location.page;
    position.offset = location.offset;

	eb_seek_text(&_book, &position);
    EBookContainer* container = [[[EBookContainer alloc] initWithEBook:self] autorelease];
	
	char buffer[1024];
	ssize_t length;
	EB_Error_Code err;
	do {
		err = eb_read_text(&_book, &_appendix, &_htmlHookset, container, sizeof(buffer) - 1, buffer, &length);
	} while (err == EB_SUCCESS && length > 0);
	
	return [container string];
}



//-- forwardContent
// 次の見出し語に移動する
- (BOOL) forwardContent
{
	EB_Error_Code err;
	if((err = eb_forward_text(&_book, &_appendix)) != EB_SUCCESS){
		NSLog(@"eb_forward_text : %s", eb_error_message(err));
		return NO;
	}
	return YES;
}


//-- hasBackwordContents
// 前のコンテンツがあるかどうかのチェック
-(BOOL) hasBackwordContents:(EBLocation*) location
{
    EB_Position position;
    position.page = location->page;
    position.offset = location->offset;
    
	if(eb_seek_text(&_book, &position) == EB_SUCCESS){
        NSInteger i = 0;
        EB_Error_Code err;
        do {
            err = eb_backward_text(&_book, &_appendix);
        }while(err == EB_SUCCESS && ++i < NUMBER_OF_WORDS);
        
		if(i > 0 && eb_tell_text(&_book, &position) == EB_SUCCESS){
            if(location){
                location->page = position.page;
                location->offset = position.offset;
            }
            return YES;
		}
	}
	return NO;
}


//-- hasSerialContents
// 続きのコンテンツがあるかどうかのチェック
-(BOOL) hasSerialContents:(EBLocation*) location
{
	EB_Position position;
	
	EB_Error_Code err = eb_tell_text(&_book, &position);
	if(_hasSerialContents && err == EB_SUCCESS){
		if(eb_seek_text(&_book, &position) == EB_SUCCESS){
			if(location){
				location->page = position.page;
				location->offset = position.offset;
			}
			return YES;
		}
	}
	return NO;
}


//-- readTextWithCode
// テキストを読み込む
- (NSAttributedString*) readTextWithParamator:(NSDictionary*) paramator
{
	EBookContainer* container = [[[EBookContainer alloc] initWithEBook:self] autorelease];
	BOOL coninuity = NO;
	
	if(paramator){
		[container setParamator:paramator];
		[container setAttribute:[paramator objectForKey:EBTextAttributes]];
		coninuity = [[paramator objectForKey:EBContentsConinuity] boolValue];
	}
	
	NSInteger i = 0;
	do {
		char buffer[1024];
		ssize_t length;
		EB_Error_Code err;
		do {
			err = eb_read_text(&_book, &_appendix, &_textHookset, container, sizeof(buffer) - 1, buffer, &length);
		} while (err == EB_SUCCESS && length > 0);
		// 追加のテキストがあるかどうかの確認
		err = eb_forward_text(&_book, &_appendix);
		if(err == EB_SUCCESS){
			NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
			[attachment setAttachmentCell:[[[LineTextAttachmentCell alloc] init] autorelease]];
		
			[container appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
			[container appendString:@"\r"];
		}else{
			coninuity = NO;
		}
	} while (coninuity && ++i < NUMBER_OF_WORDS);
	
	_hasSerialContents = coninuity;
	return [container attributedString];
}


#pragma mark Binary Data

//--- soundFrom:to:
// WAVEデータを取得する
- (NSData*) soundWithPath:(NSString*) location
{
    NSMutableData* wave = [NSMutableData dataWithCapacity:EB_SIZE_PAGE];
    char data[EB_SIZE_PAGE];
    EB_Position start, end;
    EB_Error_Code err;
    BOOL fmt = YES;
    ssize_t length;
	
	NSArray* path = [location pathComponents];
	if([path count] < 6) return nil;
	
	start.page = [[path objectAtIndex:2] intValue];
	start.offset = [[path objectAtIndex:3] intValue];
	end.page = [[path objectAtIndex:4] intValue];
	end.offset = [[path objectAtIndex:5] intValue];
		
	if((err = eb_set_binary_wave(&_book, &start, &end)) != EB_SUCCESS){
		NSLog(@"set_binary_wave : %s", eb_error_message(err));
		return nil;
	}

    do {
		err = eb_read_binary(&_book, EB_SIZE_PAGE, data, &length);
		if(fmt && (strncmp("fmt ", &data[44], 4) == 0) && (strncmp("fmt ", &data[12], 4) != 0)){
			[wave appendBytes:data length:12];
			[wave appendBytes:(&data[44]) length:(length - 44)];
		}else{
			[wave appendBytes:data length:length];
		}
		fmt = false;
    } while (err == EB_SUCCESS && length > 0);

    if(err != EB_SUCCESS){
		NSLog(@"eb_read_binary (wave) : %s", eb_error_message(err));
		return nil;
    }

    return wave;
}


//--- movieByName:
// MPEGデータを取得する
- (NSData*) movieByName : (NSString*) inPath
{
    NSMutableData* movie = [NSMutableData dataWithCapacity:EB_SIZE_PAGE];
    char data[EB_SIZE_PAGE];
    unsigned argv[4];
    EB_Error_Code err;
    ssize_t length;
    
    if((err = eb_decompose_movie_file_name(argv, [inPath UTF8String])) != EB_SUCCESS){
		NSLog(@"decompose_movie_file_name : %s", eb_error_message(err));
		return nil;
    }

    if((err = eb_set_binary_mpeg(&_book, argv)) != EB_SUCCESS){
		NSLog(@"set_binary_mpeg : %s", eb_error_message(err));
		return nil;
    }


    do {
		err = eb_read_binary(&_book, EB_SIZE_PAGE, data, &length);
		[movie appendBytes:data length:length];
	} while (err == EB_SUCCESS && length > 0);

    if(err != EB_SUCCESS){
		NSLog(@"eb_read_binary (mpeg) : %s", eb_error_message(err));
		return nil;
    }

    return movie;
}



//--- moviePath
// MPEGデータへのパスを取得する
- (NSString*) moviePath : (NSString*) inPath
{
    char movie_path_name[EB_MAX_PATH_LENGTH + 1];
    EB_Subbook *subbook;

    subbook = _book.subbook_current;
    if (subbook == NULL) {
		NSLog(@"%s", eb_error_message(EB_ERR_NO_CUR_SUB));
		return nil;
    }

    if (eb_find_file_name3(_book.path, subbook->directory_name,
			   subbook->movie_directory_name, [inPath UTF8String], movie_path_name) != EB_SUCCESS) {
		NSLog(@"%s", eb_error_message(EB_ERR_NO_SUCH_BINARY));
		return nil;
    }
    eb_compose_path_name3(_book.path, subbook->directory_name,
			  subbook->movie_directory_name, [inPath UTF8String], movie_path_name);

    return [[NSFileManager defaultManager] stringWithFileSystemRepresentation:movie_path_name
																	   length:strlen(movie_path_name)];
}



//-- imageAt:type:size
// イメージの取得
- (NSImage*) imageAt : (EBLocation) inLocate
                type : (EBImageType) inStyle
                size : (SSize) inSize
{
	EB_Position pos;
    char data[EB_SIZE_PAGE];
    EB_Error_Code err;
    NSMutableData* image = [NSMutableData dataWithCapacity:EB_SIZE_PAGE];
    ssize_t length;
    int width = inSize.width;
    int height = inSize.height;
    
    pos.page = inLocate.page;
    pos.offset = inLocate.offset;

    switch (inStyle) {
		case kImageTypeColor:
			err = eb_set_binary_color_graphic(&_book, &pos);
			break;

		case kImageTypeMono:
			err = eb_set_binary_mono_graphic(&_book, &pos, width, height);
			break;

		default:
			err = EB_ERR_BAD_FILE_NAME;
			break;
    }
	
    if(err != EB_ERR_NO_SUCH_BINARY){
		do {
			err = eb_read_binary(&_book, EB_SIZE_PAGE, data, &length);
				if (err == EB_SUCCESS && length > 0) {
					[image appendBytes:data length:length];
				}
		} while (err == EB_SUCCESS && length > 0);
    }
    
    if(err != EB_SUCCESS){
		NSLog(@"failed to set_binary_graphic : %s", eb_error_message(err));
		return nil;
    }
    
    return [[[NSImage alloc] initWithData:image] autorelease];
}


#pragma mark Font
//-- setFontSize
// 外字フォントのビットマップのサイズを決定する
- (void) setFontSize
{
    EB_Font_Code fontlist[EB_MAX_FONTS];
    int fontcount;
    int i;

    _largeFontType = _smallFontType = EB_FONT_16;
    if (eb_font_list(&_book, fontlist, &fontcount) != EB_SUCCESS) {
        NSLog(@"eb_font_list() failed.");
        return;
    }

    // あんまり綺麗ではないけどこれでいいか…
    for (i = 0; i < fontcount; i++) {
        if (fontlist[i] > _largeFontType) _largeFontType = fontlist[i];
    }
}


//-- fontImageWithCode:kind:size
// 外字フォントのビットマップを生成する
- (NSImage*) fontImageWithCode : (int) inCode
						 kind : (int) inKind
						 size : (int) inSize
{
	NSColor* blackColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	return [self fontImageWithCode:inCode kind:inKind size:inSize color:blackColor];
}


//-- fontImageWithCode:kind:size
// 外字フォントのビットマップを生成する
- (NSImage*) fontImageWithCode:(int) code
						 kind:(int) kind
						 size:(int) size
						color:(NSColor*) color
{
    unsigned char bitmap[EB_SIZE_WIDE_FONT_48];
    unsigned char imagedata[EB_SIZE_FONT_IMAGE];
    int width, height;
    size_t imagesize;
    EB_Error_Code err;
    int fontsize;

    fontsize = (size == kFontImageSizeLarge) ? _largeFontType : _smallFontType;
  
    eb_set_font(&_book, fontsize);
    width = fontsize;
    
    err = eb_font_height(&_book, &height);
    if(err != EB_SUCCESS){
		NSLog(@"eb_font_height:%s",eb_error_message(err));
		return NULL;
    }
    
    err = (kind == kFontTypeNarrow) ?
		eb_narrow_font_width(&_book, &width) : eb_wide_font_width(&_book, &width);
    if(err != EB_SUCCESS){
		NSLog(@"eb_*_font_width:%s", eb_error_message(err));
		return NULL;
    }
    
    err = (kind == kFontTypeNarrow) ?
		eb_narrow_font_character_bitmap(&_book, code, (char*)bitmap)
		: eb_wide_font_character_bitmap(&_book, code, (char*)bitmap);
    if(err != EB_SUCCESS){
		NSLog(@"eb_wide_font_character_bitmap:%s", eb_error_message(err));
		return NULL;
    }
    
	if(!color){
		color = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	}
	unsigned int rgb = ((int)([color redComponent] * 0xFF) << 16) +
						((int)([color greenComponent] * 0xFF) << 8) +
						 (int)([color blueComponent] * 0xFF);
	eb_bitmap_to_png2((char*)bitmap, width, height, (char*)imagedata, &imagesize, rgb);
	eb_unset_font(&_book);

    return [[[NSImage alloc] initWithData:[NSData dataWithBytes:imagedata length:imagesize]] autorelease];
}


//-- stringWithCode
// 代替文字を返す
- (NSString*) stringWithCode : (int) code 
						kind : (int) kind
{
	NSString* key = [[NSNumber numberWithInt:code] stringValue];
	
	NSDictionary* dic = (kind == kFontTypeNarrow) ? 
		[_narrowFontDic objectForKey:key] : [_wideFontDic objectForKey:key];
    NSString* alternative = dic ? [dic objectForKey:kAlternativeString] : nil;
    return (alternative != nil) ? alternative : @"?";
}


//-- useAlternativeWithCode:kind
// 代替文字を使うかどうかの設定
-(BOOL) useAlternativeWithCode:(int) code
						  kind:(int) kind
{
	NSString* key = [[NSNumber numberWithInt:code] stringValue];
	
	NSDictionary* item = (kind == kFontTypeNarrow) ? 
		[_narrowFontDic objectForKey:key] : [_wideFontDic objectForKey:key];
	return item ? [[item objectForKey:kUseAlternativeString] boolValue] : NO;
}


//-- setStringWithCode
// 代替文字の設定
- (void) setStringWithCode:(int) code
					  kind:(int) kind
					string:(NSString*) string
{
	[self setAlternativeString:string use:[self useAlternativeWithCode:code kind:kind] code:code kind:kind];
}


//-- setUseAlternative:code:kind
// 代替文字を使うかどうかの設定
-(void) setUseAlternative:(BOOL)use code:(int)code kind:(int)kind
{
	[self setAlternativeString:[self stringWithCode:code kind:kind] use:use code:code kind:kind];
}


//-- setAlternativeString:use:code:kind
// 代替文字列に関する設定を変更する
-(void) setAlternativeString:(NSString*) alternative
						 use:(BOOL) use
						code:(int) code
						kind:(int) kind
{
	if(!yes){
		yes = [[NSNumber alloc] initWithBool:YES];
		no = [[NSNumber alloc] initWithBool:NO];
	}
	
	NSString* key = [[NSNumber numberWithInt:code] stringValue];
	NSNumber* useAlternative = use ? yes : no;
	NSDictionary* item = [NSDictionary dictionaryWithObjectsAndKeys:
						  alternative, kAlternativeString, useAlternative, kUseAlternativeString, nil];
	
	if (kind == kFontTypeNarrow) {
		[_narrowFontDic setObject:item forKey:key];
	}else{
		[_wideFontDic  setObject:item forKey:key];
    }
}

//-- createFontTableWithProparty:kind
// フォントテーブルの生成
- (void) createFontTableWithProparty:(NSDictionary*) proparty
								kind:(int) kind
{
   if(!yes){
		yes = [[NSNumber alloc] initWithBool:YES];
		no = [[NSNumber alloc] initWithBool:NO];
	}
	
	NSMutableDictionary *table = [[NSMutableDictionary alloc] initWithCapacity:1];
	eb_set_font(&_book, EB_FONT_16);
 
	int ch;
    EB_Error_Code err = (kind == kFontTypeNarrow) ? 
		eb_narrow_font_start(&_book, &ch) : eb_wide_font_start(&_book, &ch);
    if(err != EB_SUCCESS){
		[table release];
        return;
    }
    
    while(ch >= 0){
		NSString* key = [NSString stringWithFormat:@"%d", ch];
		NSString* alternative = @"?";
		NSNumber* useAlternative = no;
		
		if(proparty){
			id item = [proparty valueForKey:key];
			if([item isKindOfClass:[NSDictionary class]]){
				alternative = [item valueForKey:kAlternativeString];
				useAlternative = [[item valueForKey:kUseAlternativeString] boolValue] ? yes : no;
			}else if([item isKindOfClass:[NSString class]]){
				alternative = item;
				useAlternative = [alternative isEqualToString:@"?"] ? no : yes;
			}
		}
		
		NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:
							   useAlternative, kUseAlternativeString,
							   alternative, kAlternativeString, nil];
		[table setObject:entry forKey:key];
		
		if(kind == kFontTypeNarrow){
			eb_forward_narrow_font_character(&_book, 1, &ch);
		}else{
			eb_forward_wide_font_character(&_book, 1, &ch);
		}
    }
    eb_unset_font(&_book);
	if(kind == kFontTypeNarrow){
		[_narrowFontDic release];
		_narrowFontDic = table;
    }else{
		[_wideFontDic release];
		_wideFontDic = table;
	}
}


//-- createFontTableAll
// すべてのフォントテーブルを生成する
- (void) createFontTableAll
{
    [self createFontTableWithProparty:nil kind:kFontTypeNarrow];
    [self createFontTableWithProparty:nil kind:kFontTypeWide];
}


//-- fontTable
// 外字一覧を返す
- (NSArray*) fontTable : (int) inKind
{
    NSMutableArray* array;
    NSArray* keys;
    NSDictionary* dict;
    int value, i, count;
    
    dict = (inKind == kFontTypeNarrow) ? _narrowFontDic : _wideFontDic;
	
    keys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    array = [NSMutableArray arrayWithCapacity:[dict count]];
    count = [keys count];
	
    for (i=0; i<count; i++) {
		value = [[keys objectAtIndex:i] intValue];
		[array addObject:[self fontTableElementWithCode:value kind:inKind]];
    }
    return array;
}


//-- fontTableElementWithCode:kind:
// fontTableElementを返す
-(FontTableElement*) fontTableElementWithCode:(int) code
										 kind:(int) kind
{
	NSString* kchar = (kind == kFontTypeNarrow) ? @"n" : @"w";
	NSString* path = [NSString stringWithFormat:@"/%lu/%@/%d", (unsigned long)_ebookNumber, kchar, code];
	
	return [FontTableElement elementWithURL:path
								alternative:[self stringWithCode:code kind:kind]
										use:[self useAlternativeWithCode:code kind:kind]
								   identify:code];
}


#pragma Search Method
//-- haveSearchMethod
// 指定した検索手順を持っているかどうか
- (BOOL) haveSearchMethod : (ESearchMethod) inMethod
{
    BOOL haveMethod = NO;
    
    switch (inMethod) {
	case kSearchMethodWord:
	    haveMethod = (eb_have_word_search(&_book) == 1) ? YES : NO;
	    break;
	case kSearchMethodEndWord:
	    haveMethod = (eb_have_endword_search(&_book) == 1) ? YES : NO;
	    break;
	case kSearchMethodKeyword:
	    haveMethod = (eb_have_keyword_search(&_book) == 1) ? YES : NO;
	    break;
	case kSearchMethodMenu:
		haveMethod = (eb_have_menu(&_book) == 1) ? YES : NO;
		break;
	case kSearchMethodMulti:
	    haveMethod = (eb_have_multi_search(&_book) == 1) ? YES : NO;
	    break;
	default:
		break;
    }

    return haveMethod;
}

#pragma mark Propaty File
//-- propertyPath
// プロパティリストを保存するパスを返す
-(NSString*) propertyPath
{
	NSString* filename = [NSString stringWithFormat:@"%@.plist", [self directoryName]];
	NSString* path = MakeGaijiFolder();
	
	return [path stringByAppendingPathComponent:filename];
}		


//-- oldPropertyPath
// コトノコ1.x時代のプロパティリストのパスを返す
-(NSString*) oldPropertyPath
{
	NSString* dict = [self directoryName];
	NSArray* array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	if([array count] == 1){
		NSString* path = [[array objectAtIndex:0] stringByAppendingPathComponent:@"eblp"];
		return [path stringByAppendingPathComponent:dict];
	}
    return nil;
}


//-- bandledPropertyPath
// パッケージ内のプロパティリストのパスを返す
-(NSString*) bandledPropertyPath
{
	NSString* filename = [NSString stringWithFormat:@"%@.plist", [self directoryName]];
	NSString* dirname = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/"];
	return [dirname stringByAppendingPathComponent:filename];
}


//-- savePrefToFile
// 辞書毎の設定をファイルに出力する　
-(void) savePrefToFile:(NSString*) inPath
				format:(NSInteger) format
{
	// nilならデフォルトの場所に保存　
	NSString* path = (inPath != nil) ? inPath : [self propertyPath];
	if (!path) return;
	
	if(format == kFileFormat1x){
		[self save1xPropertyToFile:path];
	}else{
		// 外字フォントの保存　
		NSDictionary* property= [NSDictionary dictionaryWithObjectsAndKeys:
								 _narrowFontDic, kNarrowFontTable,
								 _wideFontDic, kWideFontTable, nil];
		NSString* error;
		NSData* data = [NSPropertyListSerialization dataFromPropertyList:property 
																  format:NSPropertyListBinaryFormat_v1_0 
														errorDescription:&error];
		if(!data){
			NSLog(@"%@", error);
			[error release];
		}
	
		[data writeToFile:path atomically:NO];
	}
}


//-- loadPrefFromFile
// 辞書毎の設定をファイルから読み込む
-(void) loadPrefFromFile:(NSString*) filepath
{
	NSFileManager* fm = [NSFileManager defaultManager];
	// 指定されたファイル, コトノコの設定ファイルから読み込む
	NSString* path = (filepath != nil) ? filepath : [self propertyPath];
	if(path == nil || [fm fileExistsAtPath:path] == NO){
		// コトノコ1.xの設定ファイルを利用する
		path = [self oldPropertyPath];
		if([fm fileExistsAtPath:path] == YES){ // 設定ファイルの変換
			[self convert1xPropertyWithPath:path];
			return;
		}
		// パッケージ内の設定ファイルを利用する
		path = [self bandledPropertyPath];
		if([[NSFileManager defaultManager] fileExistsAtPath:path] == NO){
			[self createFontTableAll];
			return;
		}
	}
	NSData *data = [NSData dataWithContentsOfFile:path];
	NSString *error;
	NSPropertyListFormat format;
	id property = [NSPropertyListSerialization propertyListFromData:data
												   mutabilityOption:NSPropertyListImmutable
															 format:&format
												   errorDescription:&error];
	if(!property) { NSLog(@"%@", error); [error release]; };
	if([property isKindOfClass:[NSArray class]]){
		[self convert1xPropertyWithPath:path];
	}else{
		[self createFontTableWithProparty:[property valueForKey:kNarrowFontTable] kind:kFontTypeNarrow];
		[self createFontTableWithProparty:[property valueForKey:kWideFontTable] kind:kFontTypeWide];
	}
}




//-- convert1xPropertyWithPath
// コトノコ1.xの設定ファイルを2.x形式に変換する
-(void) convert1xPropertyWithPath:(NSString*) path
{
	NSArray *propaty = [NSArray arrayWithContentsOfFile:path];
	if([propaty count] > 1){
		[self createFontTableWithProparty:[propaty objectAtIndex:0] kind:kFontTypeNarrow];
		[self createFontTableWithProparty:[propaty objectAtIndex:1] kind:kFontTypeWide];
	}
	[self savePrefToFile:nil format:kFileFormat2x];
}


//-- convertFontDictionaryTo1xProperty
// コトノコ1.xの設定ファイル形式に外字一覧を変更する
-(NSDictionary*) convertFontDictionaryTo1xProperty:(NSDictionary*) dictionary
{
	NSMutableDictionary* property = [NSMutableDictionary  dictionaryWithCapacity:[dictionary count]];
	
	NSEnumerator* e = [dictionary keyEnumerator];
	NSString* key;
	while(key = [e nextObject]){
		NSDictionary* entry = [dictionary objectForKey:key];
		NSString* alt = [entry objectForKey:@"alternativeString"];
		if(!alt || [alt length] == 0){
			alt = @"?";
		}
		[property setObject:alt forKey:key];
	}
	return property;
}


//-- save1xPropertyToFile
// コトノコ1.x設定でファイルを保存する
-(void) save1xPropertyToFile:(NSString*) path
{
	// 辞書のその他の項目についての設定　
	NSDictionary* dictInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [self tagName], EBDictionaryTagName1xFormat,
							  [self directoryName], EBDictionaryName1xFormat,
							nil];
	// 外字フォント　
	NSArray* pref = [NSArray arrayWithObjects:
					 [self convertFontDictionaryTo1xProperty:_narrowFontDic],
					 [self convertFontDictionaryTo1xProperty:_wideFontDic],
					 dictInfo, nil];
	[pref writeToFile:path atomically:YES];
}

@end
