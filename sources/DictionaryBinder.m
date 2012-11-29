//	DictionaryBinder.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "PreferenceModal.h"
#import "DictionaryListItem.h"
#import "DictionaryBinder.h"
#import "ACBindingItem.h"
#import "DictionaryManager.h"
#import "KeyEquivalentManager.h"
#import "EBook.h"

const NSString* kTagBindingIdentifier = @"tagName";
const NSString* kTitleBindingIdentifier = @"title";
const NSString* kKeyEquivalentBindingIdentifier = @"keyEquivalent";
const NSString* kDictionaryListBindingIdentifier = @"dictionaryList";
const NSString* kQuickTabBindingIdentidier = @"quickTag";

static unsigned sBinderIdentifier = kFirstBinderId;


@implementation DictionaryBinder
@synthesize index = _index;
@synthesize prefId = _prefId;

//-- init
// 初期化
-(id) init
{
	self = [super init];
    if(self){
        [self setBinderId:sBinderIdentifier++];
	}
	return self;
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[[KeyEquivalentManager sharedKeyEquivalentManager] unsetKeyEquivalent:_keyEquivalent toObject:self];
	[self unbindAll];
	
	[_bindingItems release];
	[_tagName release];
	[_title release];
	[_keyEquivalent release];
	[_index release];
	[super dealloc];
}


//-- finalize
// 後片付け
-(void) finalize
{
	[[KeyEquivalentManager sharedKeyEquivalentManager] unsetKeyEquivalent:_keyEquivalent toObject:self];
	[self unbindAll];
	[super finalize];
}


#pragma mark Binding

//-- bindingItems
// bindingItemを返す
-(NSDictionary*) bindingItems
{
	if(!_bindingItems){
		_bindingItems = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			[ACBindingItem bindingItemFromSelector:@selector(observeTagName:)
										valueClass:[NSString class]
										identifier:kTagBindingIdentifier]
			, kTagBindingIdentifier,
			[ACBindingItem bindingItemFromSelector:@selector(observeTitle:)
										valueClass:[NSString class]
										identifier:kTitleBindingIdentifier]
			, kTitleBindingIdentifier,
			[ACBindingItem bindingItemFromSelector:@selector(observeQuickTab:)
										valueClass:[NSNumber class]
										identifier:kQuickTabBindingIdentidier]
			, kQuickTabBindingIdentidier,
			[ACBindingItem bindingItemFromSelector:@selector(observeKeyEquivalent:)
										valueClass:[NSString class]
										identifier:kKeyEquivalentBindingIdentifier]
			, kKeyEquivalentBindingIdentifier, nil];
	}
	
	return _bindingItems;
}



//-- valueClassForBinding:
//
-(Class) valueClassForBinding:(NSString *)binding {
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		return [item valueClass];
	}else{
		return [super valueClassForBinding:binding];
	}
}



//-- bind:toObject:withKeyPath:options:
//
- (void)		bind : (NSString *) binding
			toObject : (id) observableObject
		 withKeyPath : (NSString *) keyPath
			 options : (NSDictionary *) options
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		[item setObservedController:observableObject];
		[item setObservedKeyPath:keyPath];
		[item setTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:[item identifier]];
		[self performSelector:[item selector] withObject:item];
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
	ACBindingItem* item = [[self bindingItems] objectForKey:context];
	if(item){
		[self performSelector:[item selector] withObject:item];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}    


//-- infoForBinding
//
- (NSDictionary*) infoForBinding : (NSString *) binding
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		return [item infoForBinding];
	}else{
		return [super infoForBinding:binding];
	}
}


//-- unbind
// 
- (void) unbind : (NSString *) binding
{
	ACBindingItem* item = [[self bindingItems] objectForKey:binding];
	if(item){
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}else{
		[super unbind:binding];
	}
}


//-- unbindAll
// 全てのobserverからselfを除く
-(void) unbindAll
{
	NSEnumerator* e = [[self bindingItems] objectEnumerator];
	ACBindingItem* item;
	while(item = [e nextObject]){
		[[item observedController] removeObserver:self forKeyPath:[item observedKeyPath]];
		[item unbind];
	}
}

#pragma mark Observer

//-- observeTagName
// タグ名の設定
-(void) observeTagName:(ACBindingItem*) item
{
	[self willChangeValueForKey:@"tagName"];
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	[_tagName release];
	_tagName = (value && [value isKindOfClass:[NSString class]]) ?
		[value copyWithZone:[self zone]] : [[NSString alloc] initWithString:@""];
	[self didChangeValueForKey:@"tagName"];
}


//-- observeTitle
// タイトルの設定
-(void) observeTitle:(ACBindingItem*) item
{
	//[self willChangeValueForKey:@"title"];
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	[_title release];
	_title = (value && [value isKindOfClass:[NSString class]]) ?
		[value copyWithZone:[self zone]] : [[NSString alloc] initWithString:@""];
	//[self didChangeValueForKey:@"title"];
}


//-- observeQuickTab
// クイックタグに含めるかどうかの判定
-(void) observeQuickTab:(ACBindingItem*) item
{
	//[self willChangeValueForKey:@"quickTag"];
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		_quickTag = [value boolValue];
	}
	//[self didChangeValueForKey:@"quickTag"];
}


//-- observeKeyEquivalent
// ショートカットの設定
-(void) observeKeyEquivalent:(ACBindingItem*) item
{
	[self willChangeValueForKey:@"keyEquivalent"];
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	
	if(value && [value isKindOfClass:[item valueClass]]){
		KeyEquivalentManager* km = [KeyEquivalentManager sharedKeyEquivalentManager];
		[km unsetKeyEquivalent:value toObject:self];
		
		_keyEquivalent = [value copyWithZone:[self zone]];
		[km setKeyEquivalent:value toObject:self];
	}
	[self didChangeValueForKey:@"keyEquivalent"];
}


#pragma mark Interface
//-- tagName
// タグを返す
-(NSString*) tagName
{
	return (_tagName && [_tagName length] > 0) ? _tagName : _title;
}


//-- setTag
// タグの設定
-(void) setTagName:(NSString*) tagName
{
	[_tagName release];
	_tagName = (tagName && [tagName isKindOfClass:[NSString class]]) ?
		[tagName copyWithZone:[self zone]] : [[NSString alloc] initWithString:@""];
	
	ACBindingItem* item = [[self bindingItems] objectForKey:(NSString*)kTagBindingIdentifier];
	if(item && [item observedController]){
		[[item observedController] setValue:_tagName forKeyPath:[item observedKeyPath]];
	}
}


//-- title
// タイトルを返す
-(NSString*) title
{
	return _title;
}


//-- setTitle
// タイトルの設定
-(void) setTitle:(NSString*) title
{
	[_title release];
	_title = (title && [title isKindOfClass:[NSString class]]) ?
		[title copyWithZone:[self zone]] : [[NSString alloc] initWithString:@""];
	
	ACBindingItem* item = [[self bindingItems] objectForKey:(NSString*)kTitleBindingIdentifier];
	if(item && [item observedController]){
		[[item observedController] setValue:_tagName forKeyPath:[item observedKeyPath]];
	}
}


//-- identifier
// IDを返す
-(NSUInteger) binderId
{
	return _identifier;
}


//-- setIdNumber
// IDの設定
-(void) setBinderId:(unsigned) identifier
{
	_identifier = identifier;
}

//-- quickTag
// quick tagに含まれるかどうか
-(BOOL) quickTag
{
	return _quickTag;
}


//-- setQuickTag
// quick tagに含めるかどうかの設定
-(void) setQuickTag:(BOOL) isQuick
{
	_quickTag = isQuick;
	
	ACBindingItem* item = [[self bindingItems] objectForKey:(NSString*)kQuickTabBindingIdentidier];
	if(item && [item observedController]){
		[[item observedController] setValue:[NSNumber numberWithBool:_quickTag] forKeyPath:[item observedKeyPath]];
	}
}


//-- keyEquivalent
// ショートカット
-(NSString*) keyEquivalent
{
	return _keyEquivalent;
}


//-- setKeyEquivalent
// ショートカットの設定
-(void) setKeyEquivalent:(NSString*) keyEquivalent
{
	KeyEquivalentManager* km = [KeyEquivalentManager sharedKeyEquivalentManager];
	[km unsetKeyEquivalent:_keyEquivalent toObject:self];
	[_keyEquivalent release];
	
	_keyEquivalent = [keyEquivalent copyWithZone:[self zone]];
	[km setKeyEquivalent:keyEquivalent toObject:self];
	
	ACBindingItem* item = [[self bindingItems] objectForKey:(NSString*)kKeyEquivalentBindingIdentifier];
	if(item && [item observedController]){
		[[item observedController] setValue:_keyEquivalent forKeyPath:[item observedKeyPath]];
	}
}


#pragma mark Search
//-- search:method:max
// 検索
-(NSArray*) search:(NSString*)word
			method:(ESearchMethod)method
			   max:(NSInteger)maxHits
		 paramator:(NSDictionary*)paramator
{
	return nil;
}


//-- searchMethods
// 検索手法を返す
-(NSArray*) searchMethods
{
	return nil;
}

#pragma mark Copyright
//-- copyright
// コピーライトを返す
-(NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator
{
	return [[[NSAttributedString alloc] initWithString:@""] autorelease];
}

@end

#pragma mark -

@implementation SingleBinder
//-- initWithDictionaryListItem
// 初期化
-(id) initWithDictionaryListItem:(DictionaryListItem*) item
{
	self = [super init];
    if(self){
        [self bind:@"tagName" toObject:item withKeyPath:@"tagName" options:nil];
        [self bind:@"title" toObject:item withKeyPath:@"title" options:nil];
        _ebook = [[item valueForKey:@"id"] copyWithZone:[self zone]];
        id dictionaryPreference = [PreferenceModal dictioanryPreferenceForId:_ebook];
        [self bind:@"quickTag" toObject:dictionaryPreference withKeyPath:@"quickTag" options:nil];
        [self bind:@"keyEquivalent" toObject:dictionaryPreference withKeyPath:@"dictionaryPreference" options:nil];
    
        _prefId = [_ebook copyWithZone:[self zone]];
        NSNumber* idx = [dictionaryPreference valueForKey:@"index"];
        _index = idx ? [idx copyWithZone:[self zone]] : [NSNumber numberWithUnsignedInt:0];
	}
	return self;
}


//-- binderWithDictionaryListItem
// コンストラクタ
+(SingleBinder*) binderWithDictionaryListItem:(DictionaryListItem*) item
{
	return [[[SingleBinder alloc] initWithDictionaryListItem:item] autorelease];
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_ebook release];
	[super dealloc];
}

#pragma mark Search
//-- search:method:max
// 検索を行う
-(NSArray*) search:(NSString*)word
			method:(ESearchMethod)method
			   max:(NSInteger)maxHits
		 paramator:(NSDictionary*)paramator
{
	id <DictionaryProtocol> item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	if(item){
		return [item search:word method:method max:maxHits paramator:paramator];
	}
	return nil;
}


//-- searchMethods
// 利用可能な検索方式を返す
-(NSArray*) searchMethods
{
	//NSMutableArray* searchMethods = [[[NSMutableArray alloc] init] autorelease];
	id <DictionaryProtocol> item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	
	return [item searchMethods];
}


#pragma mark Copyright
//-- copyright
// コピーライトを返す
-(NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator
{
	id item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb copyrightWithParamator:paramator];
}


//-- menu
// メニューを返す
-(NSAttributedString*) menuWithParamator:(NSDictionary*) paramator
{
	id item = 
		[[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb menuWithParamator:paramator];
}


#pragma mark GAIJI Font
//-- fontTable
// 外字用フォントテーブルを返す
-(NSArray*) fontTable:(NSInteger) kind
{
	id item = 
		[[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];

	return [eb fontTable:kind];
}


//-- savePrefToFile
// propatyをファイルに書き出す
-(void) savePrefToFile:(NSString*) filename
				format:(NSInteger) format
{
	id item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb savePrefToFile:filename format:format];
}


//-- loadPrefToFile
// propatyをファイルに書き出す
-(void) loadPrefFromFile:(NSString*) filename
{
	id item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb loadPrefFromFile:filename];
}

#pragma mark Multi Search
//-- multiSearchEntries
// 複合検索のエントリを返す
-(NSArray*) multiSearchEntries:(NSInteger) idx
{
	id item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb arrayMultiSearchEntry:idx];
}


//-- multiSearchCandidates
// 検索語候補を返す
-(NSArray*) multiSearchCandidates:(NSInteger) idx
							entry:(NSInteger) entry
{
	id item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb arrayMultiSearchCandidates:idx at:entry];
}



//-- multiSearch:
// 複合検索を行う
-(NSArray*) multiSearch:(NSArray*) entries
				  index:(NSInteger) idx
					max:(NSInteger)maxHits
			  paramator:(NSDictionary*)paramator
					
{
	id item = [[DictionaryManager sharedDictionaryManager] dictionaryForIdentity:_ebook];
	EBook* eb = [item valueForKey:@"ebook"];
	
	return [eb multiSearch:entries index:idx max:maxHits paramator:paramator];
}

@end



#pragma mark -
@implementation MultiBinder
//-- initWithParamators
// 初期化
-(id) initWithParamators:(NSMutableDictionary*)paramators prefId:(NSString*)identify
{
	self = [super init];
	if(self){
		_dictionaryList = [[NSMutableArray alloc] init];
		[self bind:@"tagName" toObject:paramators withKeyPath:@"title" options:nil];
		[self bind:@"title" toObject:paramators withKeyPath:@"title" options:nil];
		[self bind:@"quickTag" toObject:paramators withKeyPath:@"quickTag" options:nil];
		[self bind:@"dictionaryList" toObject:paramators withKeyPath:@"dictionaries" options:nil];
		[self bind:@"keyEquivalent" toObject:paramators withKeyPath:@"dictionaryPreference" options:nil];
		_prefId = [identify copyWithZone:[self zone]];
		id pref = [PreferenceModal dictioanryPreferenceForId:_prefId];
		if(pref){
			NSNumber* idx = [pref valueForKey:@"index"];
			_index = idx ? [idx copyWithZone:[self zone]] : [NSNumber numberWithUnsignedInt:0];
		}
	}
	return self;
}


//-- binderWithParamators
// コンストラクタ
+(MultiBinder*) binderWithParamators:(NSMutableDictionary*)params prefId:(NSString*)identify
{
	return [[[MultiBinder alloc] initWithParamators:params prefId:(NSString*)identify] autorelease];
}


//-- dealloc
// 後片付け
-(void) dealloc
{
	[_dictionaryList release];
	[super dealloc];
}


#pragma mark Binding
//-- bindingItems
// bindingItemを返す
-(NSDictionary*) bindingItems
{
	if(!_bindingItems){
		if(![super bindingItems]){
			_bindingItems = [[NSMutableDictionary alloc] init];
		}
		[_bindingItems setObject:[ACBindingItem bindingItemFromSelector:@selector(observeDictionaryList:)
															 valueClass:[NSArray class]
															 identifier:kDictionaryListBindingIdentifier]
						  forKey:(NSString*)kDictionaryListBindingIdentifier];
	}
	
	return _bindingItems;
}

//-- addDictionaryIdentify
// 辞書の追加
-(void) addDictionaryIdentify:(NSString*) identify
{
	[_dictionaryList addObject:identify];
}


#pragma mark Observers
//-- observeDictionaryList
// 辞書名の設定
-(void) observeDictionaryList:(ACBindingItem*) item
{
	//[self willChangeValueForKey:@"dictionaryList"];
	[_dictionaryList removeAllObjects];
	id value = [[item observedController] valueForKeyPath:[item observedKeyPath]];
	if(value && [value isKindOfClass:[item valueClass]]){
		NSEnumerator* e = [value objectEnumerator];
		NSString* it;
		DictionaryManager* dm = [DictionaryManager sharedDictionaryManager];
		while(it = [e nextObject]){
			if([dm dictionaryForIdentity:it] != nil){
				[self addDictionaryIdentify:it];
			}
		}
	}
	//[self didChangeValueForKey:@"dictionaryList"];
}

#pragma mark Interface
//-- setTag
// タグの設定
-(void) setTagName:(NSString*) tagName
{
	[self willChangeValueForKey:@"title"];
	[super setTagName:tagName];
	[self didChangeValueForKey:@"title"];
}

#pragma mark Search
//-- search:method:max
// 検索を行う
-(NSArray*) search:(NSString*)word
			method:(ESearchMethod)method
			   max:(NSInteger)maxHits
		 paramator:(NSDictionary*)paramator
{
	NSMutableArray* array = [[NSMutableArray alloc] init];
	NSEnumerator* e = [_dictionaryList objectEnumerator];
	NSString* it;
	DictionaryManager* dm = [DictionaryManager sharedDictionaryManager];
	while(it = (NSString*)[e nextObject]){
		id <DictionaryProtocol> item = [dm dictionaryForIdentity:it];
		if(item){
			NSArray* results = [item search:word method:method max:maxHits paramator:paramator];
			if(results){
				[array addObjectsFromArray:results];
			}
		}
	}

	return [array autorelease];
}


//-- searchMethods
// 検索可能な検索手法のリストを返す
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
	return searchMethods;
}


//-- hasSearchMethod
// 検索可能かどうかの判定 1つの辞書でも検索可能であれば検索可能とする
-(BOOL) hasSearchMethod:(ESearchMethod) method
{
	NSEnumerator* e = [_dictionaryList objectEnumerator];
	NSString* it;
	DictionaryManager* dm = [DictionaryManager sharedDictionaryManager];
	while(it = (NSString*)[e nextObject]){
		id <DictionaryProtocol> item = [dm dictionaryForIdentity:it];
		if(item && [item hasSearchMethod:method]){
			return YES;
		}
	}
	return NO;
}


#pragma mark Copyright
//-- copyright
// コピーライトを返す
-(NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator
{
	NSMutableAttributedString* copyright = [[NSMutableAttributedString alloc] initWithString:@""];
	NSMutableParagraphStyle* style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setAlignment:NSCenterTextAlignment];
	
	[copyright appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\r\r"] autorelease]];
	
	[copyright appendAttributedString:
	 [[[NSAttributedString alloc] initWithString:[self tagName]
									  attributes:[paramator objectForKey:EBTextAttributes]] autorelease]];
	[copyright addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [copyright length])];
	[copyright appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\r\r\r"] autorelease]];
	
	NSEnumerator* e = [_dictionaryList objectEnumerator];
	NSString* it;
	DictionaryManager* dm = [DictionaryManager sharedDictionaryManager];
	while(it = (NSString*)[e nextObject]){
		id item = [dm dictionaryForIdentity:it];
		if(item){
			[copyright appendAttributedString:
			 [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", [item valueForKey:@"title"]]
											  attributes:[paramator objectForKey:EBTextAttributes]] autorelease]];
		}
	}
	return [copyright autorelease];
}


@end