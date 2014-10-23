//	PreferenceModal.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "PreferenceUtilities.h"
#import "PreferenceModal.h"
#import "EBookUtilities.h"

#import <WebKit/WebKit.h>

static PreferenceModal* sSharedPreferenceModal = nil;


static NSDictionary *defaultValues()
{
    static NSDictionary *defaults = nil;
    
    if(!defaults){
        defaults = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], kScanVolume,
			[NSString stringWithFormat:@"%@ %.0f",
				[[NSFont userFontOfSize:0.0] fontName],
				[[NSFont userFontOfSize:0.0] pointSize]], kHeadingFont,
			[NSString stringWithFormat:@"%@ %.0f",
			[[NSFont userFontOfSize:0.0] fontName],
				[[NSFont userFontOfSize:0.0] pointSize]], kContentsFont,
			[NSString stringWithFormat:@"%@ %.0f",
				[[NSFont labelFontOfSize:[NSFont smallSystemFontSize]] fontName],
				[NSFont smallSystemFontSize]], kQuickTabFont,
			@"0.0 0.0 0.0 1.0", kContentsColor,
			@"0.0 0.0 0.0 1.0", kHeadingColor,
			@"0.0 0.0 1.0 1.0", kIndexColor,
			@"1.0 0.0 0.0 1.0", kLinkColor,
			@".25 .25 .25 .25", kDictionaryNameColor,
			@"1.0 0.75 0.5 1.0", kFindColor,
			@"0.45 0.50 0.60 1.0", kDictionaryBackgroundColor,
			@"", kCurrentDictionary,
			[NSNumber numberWithInt:kWindowStyleAutomatic], kWindowStyle,
			[NSNumber numberWithInt:350], kWSSwitchingWidth,
			[NSNumber numberWithBool:YES], kQuitWhenNoWindow,
            [NSNumber numberWithBool:NO], kUseSmallWindow,
            [NSNumber numberWithBool:NO], kDiminishRescan,
            [NSNumber numberWithBool:NO], kShowOnlyEBookSet,
            [NSNumber numberWithInt:150], kSearchAllMax,
            [NSNumber numberWithInt:20], kContentHistoryNum,
            [NSNumber numberWithBool:YES], kPlaySoundAutomatically,
            [NSNumber numberWithBool:YES], kLinkUnderLine,
			[NSNumber numberWithBool:NO], kContentsConinuity,
			[NSNumber numberWithBool:NO], kUsePasteboardSearch,
			[NSNumber numberWithBool:NO], kUseBackgroundPastebordSearch,
			[NSNumber numberWithBool:NO], kAutoFowardingContents,
            [NSNumber numberWithInt:kFitScaleWhenLoaded], kFitWebViewScale,
            [NSNumber numberWithInt:kSwipeBehaviorSwitchPage], kSwipeBehavior,
            [NSNumber numberWithInt:10000], kContentsCharactersMax, 
			[NSArray array], kDirectoryPath,
			[NSArray array], kEBookSet,
			[NSDictionary dictionary], kDictionaryTable,
			[NSDictionary dictionary], kAppendixTable,
			[NSDictionary dictionary], kDictionaryIdTable,
            [NSDictionary dictionary], kSecureBookmarkTable,
            [NSNumber numberWithInt:kTextOrientationHorizontal], kTextOrientation,
			nil];
    }
    return defaults;
};


@implementation PreferenceModal

#pragma mark Shared Instance
//-- sharedPreferenceModal
// return shared preference 
+(PreferenceModal*) sharedPreference
{
	if(!sSharedPreferenceModal){
		sSharedPreferenceModal = [[PreferenceModal alloc] init];
	}
	return sSharedPreferenceModal;
}

//-- prefForKey
// 初期設定値を返す
+(id) prefForKey:(NSString*) key
{
	return [[PreferenceModal sharedPreference] valueForKey:key];
}


//-- colorForKey
// 色設定値を返す
+(NSColor*) colorForKey:(NSString*) key
{
	return [PreferenceUtilities transforColorNameToColor:[PreferenceModal prefForKey:key]];
}


//-- fontForKey
// フォント設定値を返す
+(NSFont*) fontForKey:(NSString*) key
{
	return [PreferenceUtilities transforFontNameToFont:[PreferenceModal prefForKey:key]];
}



//-- dictionaryIdForFullPath
// 辞書IDをフルパスから求める
+(NSString*) dictionaryIdForFullPath:(NSString*) path
{
	NSMutableDictionary* table = [PreferenceModal prefForKey:kDictionaryIdTable];
	return [table valueForKey:path];
}



//-- setDictionaryId:forFullPath
// フルパスに対応する辞書IDを設定する
+(void) setDictionaryId:(NSString*) identifier
			forFullPath:(NSString*) fullPath
{
	NSMutableDictionary* table = [PreferenceModal prefForKey:kDictionaryIdTable];
	[table setValue:identifier forKey:fullPath];
}


//-- dictionaryPreferenceForId
// 単体辞書の設定値をIDから求める
+(NSMutableDictionary*) dictioanryPreferenceForId:(NSString*) identifier
{
	NSMutableDictionary* table = [PreferenceModal prefForKey:kDictionaryTable];
	NSMutableDictionary* param = [table valueForKey:identifier];
	if(!param){
		param = [NSMutableDictionary dictionary];
		[table setValue:param forKey:identifier];
	}
	return param;
}


#pragma mark Initializing
//-- init
// 初期化
- (id) init
{
	self = [super init];
    if(self){
        if(sSharedPreferenceModal){
            return sSharedPreferenceModal;
        }
        sSharedPreferenceModal = self;
        [self preferencesFromDefaults];
    }
	return self;
}


//-- dealloc
// 削除
- (void) dealloc
{
	sSharedPreferenceModal = nil;
}


#pragma mark Bindings Interface
//-- setValue:forKey
// 値の設定
-(void) setValue:(id) value
		  forKey:(NSString*) key
{
	id newValue = value ? value : [NSNull null];
	[self willChangeValueForKey:key];
	[_preferences setObject:newValue forKey:key];
    [self didChangeValueForKey:key];
}


//-- valueForKey
// 値の取得
-(id) valueForKey:(NSString*) key
{
	return [_preferences objectForKey:key];
}



#pragma mark User Defaults
//-- preferencesFromDefaults
// 初期設定ファイルから設定をCurrentValuesに読み込む
-(void) preferencesFromDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* defaults = defaultValues();
	_preferences = [[NSMutableDictionary alloc] initWithCapacity:[defaults count]];
	
	NSEnumerator* e = [defaults keyEnumerator];
	id key;
	while(key = [e nextObject]){
		id value = [userDefaults objectForKey:key];
		if(!value){
			value = [defaults objectForKey:key];
		}
		
		if([value isKindOfClass:[NSArray class]]){
			[_preferences setObject:[self mutableArrayFromArray:value] forKey:key];
		}else if([value isKindOfClass:[NSDictionary class]]){
			[_preferences setObject:[self mutableDictionaryFromDictionary:value] forKey:key];
		}else{
			[_preferences setObject:value forKey:key];
		}
	}
}


//-- savePreferencesToDefaults
// 初期設定ファイルに設定を書き込む
-(void) savePreferencesToDefaults 
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary* defaluts = defaultValues();
	NSEnumerator* e = [defaluts keyEnumerator];
	id key;
	while(key = [e nextObject]){
		id value = [_preferences objectForKey:key];
		if(value){
			[userDefaults setObject:value forKey:key];
		}
	}
    // ファイルに書き込む
    [userDefaults synchronize];
}


//-- mutableArrayFromArray
// 設定ファイルの配列から変更可能な配列を生成する
-(NSMutableArray*) mutableArrayFromArray:(NSArray*) array
{
	NSEnumerator* e = [array objectEnumerator];
	NSMutableArray* copy = [NSMutableArray arrayWithCapacity:[array count]];
	id it;
	while(it = [e nextObject]){
		if([it isKindOfClass:[NSDictionary class]]){
			[copy addObject:[self mutableDictionaryFromDictionary:it]];
		}else if([it isKindOfClass:[NSArray class]]){
			[copy addObject:[self mutableArrayFromArray:it]];
		}else{
			[copy addObject:[it copyWithZone:nil]];
		}
	}
	return copy;
}


//-- mutableDictionaryFromDictionary
// 設定ファイルの配列から変更可能な配列を生成する
-(NSMutableDictionary*) mutableDictionaryFromDictionary:(NSDictionary*) dic
{
	NSEnumerator* e = [dic keyEnumerator];
	NSMutableDictionary* copy = [NSMutableDictionary dictionary];
	id key;
	while(key = [e nextObject]){
		id obj = [dic objectForKey:key];
		if([obj isKindOfClass:[NSDictionary class]]){
			[copy setObject:[self mutableDictionaryFromDictionary:obj] forKey:key];
		}else if([obj isKindOfClass:[NSArray class]]){
			[copy setObject:[self mutableArrayFromArray:obj] forKey:key];
		}else{
			[copy setObject:[obj copyWithZone:nil] forKey:key];
		}
	}
	return copy;
}

#pragma mark Security Scoped Bookmark
//-- setSecurityBookmark:
// Secutiry-scoped bookmarkを保存する
+(void) setSecurityBookmark:(NSData*)bookmark forPath:(NSString*)path
{
    NSMutableDictionary *table = [PreferenceModal prefForKey:kSecureBookmarkTable];
    [table setObject:bookmark forKey:path];
}


//-- setSecurityBookmark:
// Secutiry-scoped bookmarkを取得する
+(NSURL*) securityBookmarkForPath:(NSString*)path
{
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6) return nil;
    if (IsAppSandboxed() == NO) return nil;
    
    NSData *bookmark = [[PreferenceModal prefForKey:kSecureBookmarkTable] objectForKey:path];
    if(bookmark){
        NSError* error = nil;
        BOOL stale;
        NSURL* bookmarkUrl = [NSURL URLByResolvingBookmarkData:bookmark
                                                       options:NSURLBookmarkResolutionWithSecurityScope
                                                 relativeToURL:nil
                                           bookmarkDataIsStale:&stale
                                                         error:&error];
        if (stale == false && error == nil) return bookmarkUrl;
    }
    return nil;
}


@end
