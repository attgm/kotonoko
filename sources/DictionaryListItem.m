//	DictionaryListItem.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import "EBook.h"
#import "DictionaryListItem.h"
#import "PreferenceModal.h"
#import "PreferenceDefines.h"

@implementation DictionaryListItem


//-- initWithPath
// パスから初期化を行う
-(id) initWithPath:(NSString*) path
{
	self = [super init];
    if(self){
        _paramators = [[NSMutableDictionary alloc] init];
        _children = [[NSMutableArray alloc] init];
        [self setValue:[path lastPathComponent] forKey:@"title"];
        [self setValue:[[[NSFileManager defaultManager] componentsToDisplayForPath:path] 
                                                        componentsJoinedByString:@":"]
                forKey:@"displayPath"];
        [self setValue:path forKey:@"path"];
        NSString* appendix = [[PreferenceModal prefForKey:kAppendixTable] objectForKey:path];
        if(appendix) { [_paramators setValue:appendix forKey:@"appendix"]; };
	}
	return self;
}




//-- dictionaryListItemWithPath
// パスから初期化する
+(DictionaryListItem*) dictionaryListItemWithPath:(NSString*) path
{
	return [[[DictionaryListItem alloc] initWithPath:path] autorelease];
}





//-- dealloc
-(void) dealloc
{
	[_children release];
	[_paramators release];
	[super dealloc];
}


#pragma mark Bindings
//-- setValue
// 値の設定
-(void) setValue:(id) value
		  forKey:(NSString*) key
{
	id newValue = value ? value : [NSNull null];
	[self willChangeValueForKey:key];
	if([key isEqualToString:@"tagName"]){
		[self setTagName:value];
	}else if([key isEqualToString:@"appendix"]){
		[self setAppendix:value];
	}
	[_paramators setObject:newValue forKey:key];
    [self didChangeValueForKey:key];
}


//-- valueForKey
// 値の取得
-(id) valueForKey:(NSString*) key
{
	if([key isEqualToString:@"children"]){
		return _children;
	}else if([key isEqualToString:@"canHaveAppendix"]){
		NSString* type = [self valueForKey:@"type"];
		return [NSNumber numberWithBool:(type && [type isEqualToString:@"book"])];
	}else if([key isEqualToString:@"canRenameTag"]){
		NSString* type = [self valueForKey:@"type"];
		return [NSNumber numberWithBool:(type && [type isEqualToString:@"dictionary"])];
	}else if([key isEqualToString:@"tagName"]){
		return [self tagName];
	}else{
		return [_paramators objectForKey:key];
	}
}


//-- tagName
// 辞書に付加されたタグを返す
-(NSString*) tagName
{
	NSString* tag = [_paramators objectForKey:@"tagName"];
	return (tag && ![tag isKindOfClass:[NSNull class]]) ? tag : [_paramators objectForKey:@"title"];
}


//-- setTagName
// 辞書にタグを付加する
-(void) setTagName : (NSString*) value
{
	NSMutableDictionary* param = [PreferenceModal dictioanryPreferenceForId:[self valueForKey:@"id"]];
	if(value != NULL){
		[param setObject:value forKey:@"tagName"];
	}else{
		[param removeObjectForKey:@"tagName"];
	}
}


//-- setAppendix
// 付録の編集を行う
-(void) setAppendix : (NSString*) path
{
	NSMutableDictionary* tagTable = [PreferenceModal prefForKey:kAppendixTable];
	if(path != NULL){
		[tagTable setObject:path forKey:[self valueForKey:@"path"]];
	}else{
		[tagTable removeObjectForKey:[self valueForKey:@"path"]];
	}
}


//-- addChild
// 辞書を追加する
-(void) addChild:(DictionaryListItem*) item
{
	[_children addObject:item];
}


//-- children
// 辞書リストを返す
-(NSArray*) children
{
	return _children;
}


@end


@implementation EBDictionary

//-- initWithEBook:path:
// タイトルから初期化を行う
-(id) initWithEBook:(EBook*) book
			   path:(NSString*) path
		   identify:(NSString*) dictionaryId
{
	self = [super init];
    if(self){
        _paramators = [[NSMutableDictionary alloc] init];
        _children = [[NSMutableArray alloc] init];
        [self setValue:[NSString stringWithString:[book stringSubbookTitle]] forKey:@"title"];
        NSString* directoryName = [book directoryName];
        NSString* fullpath = [path stringByAppendingPathComponent:directoryName];
        [self setValue:dictionaryId forKey:@"id"];
	
        [self setValue:[[[NSFileManager defaultManager] componentsToDisplayForPath:fullpath] 
                        componentsJoinedByString:@":"]
                forKey:@"displayPath"];
        [self setValue:fullpath forKey:@"path"];
	
        NSMutableDictionary* param = [PreferenceModal dictioanryPreferenceForId:directoryName];
        NSString* tagName = [param valueForKey:@"tagName"];
        if(tagName){ [_paramators setValue:[NSString stringWithString:tagName] forKey:@"tagName"]; };
	
        [self setValue:book forKey:@"ebook"];
	
        NSString* appendix = [[PreferenceModal prefForKey:kAppendixTable] objectForKey:path];
        if(appendix) {
            NSURL* bookmark = [PreferenceModal securityBookmarkForPath:appendix];
            
            if (bookmark) [bookmark startAccessingSecurityScopedResource];
            [book bindAppendix:appendix];
            if (bookmark) [bookmark stopAccessingSecurityScopedResource];
        };
        [self setValue:@"dictionary" forKey:@"type"];
    }
	return self;
}


//-- dictionaryListItemWithEBook
// ebookから初期化する
+(EBDictionary*) dictionaryListItemWithEBook:(EBook*) book
										path:(NSString*) path
									identify:(NSString*) dictionaryId
{
	return [[[EBDictionary alloc] initWithEBook:book path:path identify:dictionaryId] autorelease];
}


#pragma mark DictionaryProtocol
//-- search
// 検索する
-(NSArray*) search:(NSString*)word
			method:(ESearchMethod)method
			   max:(NSInteger)maxHits
		 paramator:(NSDictionary*)paramator
{
	EBook* ebook = [self valueForKey:@"ebook"];
	if(method < kSearchMethodMulti){
		if(ebook && [ebook haveSearchMethod:method] == YES){
			return [ebook search:word method:method max:maxHits paramator:paramator];
		}
	}else{
		return nil;
	}
	return nil;
}


//-- hasSearchMethod
// 指定する検索メソッドを所持しているかどうかのチェック
-(BOOL) hasSearchMethod:(ESearchMethod) method
{
	EBook* ebook = [self valueForKey:@"ebook"];
	if(ebook && [ebook haveSearchMethod:method] == YES){
		return YES;
	}
	return NO;
}


#pragma mark Search Methods
//-- searchMethods
// 検索タイトルの一覧
-(NSArray*) searchMethods
{
	NSMutableArray* searchMethods = [[[NSMutableArray alloc] init] autorelease];
	
	if([self hasSearchMethod:kSearchMethodWord]){
		[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:kSearchMethodWord], @"tag",
								  @"Prefix Search", @"title", nil]];
	}
	if([self hasSearchMethod:kSearchMethodEndWord]){
		[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:kSearchMethodEndWord], @"tag",
								  @"Suffix Search", @"title", nil]];
	}
	if([self hasSearchMethod:kSearchMethodKeyword]){
		[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:kSearchMethodKeyword], @"tag",
								  @"Keyword Search", @"title", nil]];
	}
	if([self hasSearchMethod:kSearchMethodMulti]){
		if([searchMethods count] > 0){
			[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									  @"-", @"title", nil]];
		}
		NSArray* multiSearchTitles = [self multiSearchTitles];
		int tag = kSearchMethodMulti;
		for(NSString* title in multiSearchTitles){
			[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:tag++], @"tag",
									  title, @"title", nil]];
		}
	}
	if([self hasSearchMethod:kSearchMethodMenu]){
		if([searchMethods count] > 0){
			[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									  @"-", @"title", nil]];
		}
		[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:kSearchMethodMenu], @"tag",
								  @"Menu", @"title", nil]];
	}		
	return searchMethods;
}


//-- multiSearchTitles
// 複合検索のタイトル一覧の表示
-(NSArray*) multiSearchTitles
{
	EBook* ebook = [self valueForKey:@"ebook"];
	if(ebook){
		return [ebook arrayMultiSearchTitle];
	}
	return nil;
}




@end