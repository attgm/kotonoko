//	NetDictionary.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//



#import "DictionaryManager.h"
#import "NetDictionary.h"
#import "EBook.h"
#import "DictionaryElement.h"
#import "PreferenceModal.h"

@implementation NetDictionary

#pragma mark allocatior
//-- initWithData
// ネット辞書を作成する
-(id) initWithData:(NSData*) data
{
	self = [super init];
	if(self){
		if(![self parseData:data]){
			[self release];
			return nil;
		}
	}
	return self;
}


//-- netDictionaryWithData
// 辞書を作成する
+(NetDictionary*) netDictionaryWithData:(NSData*) data
{
	return [[[NetDictionary alloc] initWithData:data] autorelease];
}



//-- parseData
// データを読み込む
-(BOOL) parseData:(NSData*) data
{
	NSError *error;
	NSPropertyListFormat format;
	id property = [NSPropertyListSerialization propertyListWithData:data
                                                            options:NSPropertyListImmutable
															 format:&format
                                                              error:&error];
	if(!property){NSLog(@"%@", [error description]); return NO;};
	if(![property isKindOfClass:[NSDictionary class]]){
		return NO;
	}
	if([[property valueForKey:@"Version"] floatValue] == 1.0){
		_paramators = [property mutableCopy];
		return YES;
	}else{
		return NO;
	}
}


#pragma mark Interface

//-- setValue
// 値の設定
-(void) setValue:(id) value
		  forKey:(NSString*) key
{
	id newValue = value ? value : [NSNull null];
	[self willChangeValueForKey:key];
	if([key isEqualToString:@"tagName"]){
		[self setTagName:value];
	}else if([key isEqualToString:@"id"]){
		[self setId:value];
	}else if([key isEqualToString:@"selected"]){
		[self setSelected:[value boolValue]];
	}else{
		[_paramators setObject:newValue forKey:key];
	}
    [self didChangeValueForKey:key];
}


//-- valueForKey
// 値の取得
-(id) valueForKey:(NSString*) key
{
	if([key isEqualToString:@"tagName"]){
		return [self tagName];
	}
	return [_paramators objectForKey:key];
}


//-- paramsForMethod
// 検索メソッドを返す
-(NSDictionary*) paramsForSearchId:(NSInteger) methodId
{
	NSArray* methods = [self valueForKey:@"SearchMethods"];
	for(NSDictionary* searchMethod in methods){
		if([[searchMethod objectForKey:@"SearchID"] intValue] == methodId){
			return searchMethod;
		}
	}
	return nil;
}


//-- tag
// 辞書に付加されたタグを返す
-(NSString*) tagName
{
	NSString* tag = [_paramators objectForKey:@"tagName"];
	return (tag && ![tag isKindOfClass:[NSNull class]]) ? tag : [_paramators objectForKey:@"ShortName"];
}


//-- setTag
// 辞書にタグを付加する
-(void) setTagName : (NSString*) value
{
	NSMutableDictionary* param = [PreferenceModal dictioanryPreferenceForId:[self valueForKey:@"id"]];
	if(value != nil && ![value isKindOfClass:[NSNull class]]){
		[param setObject:value forKey:@"tagName"];
		[_paramators setObject:value forKey:@"tagName"];
	}else{
		[param removeObjectForKey:@"tagName"];
		[_paramators removeObjectForKey:@"tagName"];
	}
}


//-- selection
// 辞書を選択するかどうかの回答
-(BOOL) selected
{
	NSNumber* selection = [_paramators objectForKey:@"selected"];
	return selection ? [selection boolValue] : NO;
}



//-- setSlection
// 辞書を選択するかどうかの回答
-(void) setSelected:(BOOL) selection
{	
	NSNumber* value = [NSNumber numberWithBool:selection];
	[_paramators setObject:value forKey:@"selected"];
	
	NSMutableDictionary* param = [PreferenceModal dictioanryPreferenceForId:[self valueForKey:@"id"]];
	[param setObject:value forKey:@"selected"];
	
	if(selection){
		[[DictionaryManager sharedDictionaryManager] addDictionary:self];
	}else{
		[[DictionaryManager sharedDictionaryManager] deleteDictionary:self];
	}
}



//-- setId
// 辞書のIDを設定する
-(void) setId:(NSString*) identify
{
	[_paramators setObject:identify forKey:@"id"];
	
	NSMutableDictionary* param = [PreferenceModal dictioanryPreferenceForId:identify];
	NSString* tag = [param objectForKey:@"tagName"];
	if(tag){
		[_paramators setObject:tag forKey:@"tagName"];
	}
	NSNumber* selected = [param objectForKey:@"selected"];
	[self setSelected:(selected ? [selected boolValue] : NO)];
}


#pragma mark DictionaryProtocol
//-- search:method:max:paramator
// 検索
-(NSArray*) search:(NSString*) word
			method:(ESearchMethod) method
			   max:(NSInteger) maxHits
		 paramator:(NSDictionary*) paramator
{
	NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
	
	NSAttributedString* tagName = [[[NSAttributedString alloc] initWithString:[self valueForKey:@"ShortName"]
																   attributes:[paramator objectForKey:EBTagAttributes]] autorelease];
	[array addObject:[DictionaryElement elementWithHeading:tagName
													anchor:EBMakeLocation(0, -1, 0)]];
	
	NSDictionary* methodParamator = [self paramsForSearchId:method];
	NSString* ianaEncoding = [self valueForKey:@"InputEncoding"];
	NSStringEncoding encoding =
		CFStringConvertEncodingToNSStringEncoding(
					CFStringConvertIANACharSetNameToEncoding((CFStringRef)ianaEncoding));
	if(methodParamator){
		NSString* template = [methodParamator objectForKey:@"Template"];
		NSString* searchURL = [methodParamator objectForKey:@"SearchURL"];
		NSString* identify = [self valueForKey:@"id"];
		if (template && [template isKindOfClass:[NSString class]]) {
			NSString* url = [NSString stringWithFormat:@"web://%@/%@%@", identify, searchURL,
							 [template stringByReplacingOccurrencesOfString:@"{searchTerms}" withString:word]];
			NSString* escapedURL = [url stringByAddingPercentEscapesUsingEncoding:encoding];
			NSAttributedString* heading = [[[NSAttributedString alloc] initWithString:word
																		   attributes:[paramator objectForKey:EBTextAttributes]] autorelease];
			[array addObject:[DictionaryElement elementWithHeading:heading url:escapedURL]];
		}
	}
	return array;
}




//-- hasSearchMethod
// 検索文字列を持っているかどうか
-(BOOL)	hasSearchMethod:(ESearchMethod) method
{
	return ([self paramsForSearchId:method] != nil);
}



//-- searchMethods
// 検索タイトルの一覧
-(NSArray*) searchMethods
{
	NSMutableArray* searchMethods = [[[NSMutableArray alloc] init] autorelease];
	NSArray* methods = [self valueForKey:@"SearchMethods"];
	
	for(NSDictionary* it in methods){
		[searchMethods addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								  [it objectForKey:@"SearchID"], @"tag",
								  [it objectForKey:@"Title"], @"title", nil]];
	}
	
	return searchMethods;
}


#pragma mark -
#pragma mark Network 
//-- isDictionaryHost
// 検索用のホストかどうか
-(BOOL)	isDictionaryHost:(NSString*) serverName
{
	NSArray* hosts = [self valueForKey:@"Hosts"];
	for(NSString* host in hosts){
		if([serverName isEqualToString:host]){
			return YES;
		}
	}
	return NO;
}

@end
