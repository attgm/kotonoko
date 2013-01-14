//	DictionaryManager.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "DictionaryListItem.h"
#import "DictionaryManager.h"
#import "PreferenceModal.h"
#import "PreferenceDefines.h"
#import "EBook.h"

#import "NetDictionary.h"


DictionaryManager* sSharedDictionaryManager = NULL;

@implementation DictionaryManager
@synthesize readableAll = _readableAll;


#pragma mark Shared Instance
//-- sharedDictionaryManager
// return shared preference 
+(DictionaryManager*) sharedDictionaryManager
{
	if(!sSharedDictionaryManager){
		sSharedDictionaryManager = [[DictionaryManager alloc] init];
	}
	return sSharedDictionaryManager;
}


#pragma mark Initializing
//-- init
// 初期化
- (id) init
{
	self = [super init];
    if(self){
        if(sSharedDictionaryManager){
            [self release];
            return sSharedDictionaryManager;
        }
        sSharedDictionaryManager = self;
	
        _root = [[NSMutableArray alloc] init];
        _dictionaries = [[NSMutableArray alloc] init];
	}
	return self;
}


//-- dealloc
// メモリの解放
-(void) dealloc
{
	[_root release];
	[_dictionaries release];
	[_netDictionaries release];
	[super dealloc];
}


//-- initialize
// 初期化
-(void) initialize
{
	[self createDictionaryArray];
	[self createNetDictionaryArray];
}


#pragma mark Dictionaries
//-- addDictionary
// 辞書を追加
-(void) addDictionary:(id <DictionaryProtocol>) item
{
	NSIndexSet *indexset = [NSIndexSet indexSetWithIndex:[_dictionaries count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexset forKey:@"dictionaries"];
	[_dictionaries addObject:item];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexset forKey:@"dictionaries"];	
}


//-- removeDictionary
// 辞書を削除
-(void) deleteDictionary:(id <DictionaryProtocol>) item
{
	NSIndexSet *indexset = [NSIndexSet indexSetWithIndex:[_dictionaries count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexset forKey:@"dictionaries"];
	[_dictionaries removeObject:item];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexset forKey:@"dictionaries"];	
}


//-- deleteDictionary
// 辞書を削除
-(void) deleteDictionaryAtIndex:(NSIndexSet*) indices
{
	if(indices){
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"dictionaries"];
		[_dictionaries removeObjectsAtIndexes:indices];
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"dictionaries"];	
	}
}


//-- dictionaryForIdentity
// IDで辞書を返す
-(id <DictionaryProtocol>) dictionaryForIdentity:(NSString*) identity
{
	for(id item in _dictionaries){
		if([item respondsToSelector:@selector(valueForKey:)]){
			if([identity isEqualToString:[item valueForKey:@"id"]]){
				return item;
			}
		}
	}
	return nil;
}


//-- dictionaryForEBookNumber
// ebook numberから DictionaryListItemを返す
-(EBook*) ebookForEBookNumber:(NSUInteger) number
{
	for(id item in _dictionaries){
		if([item respondsToSelector:@selector(valueForKey:)]){
			EBook* eb = [item valueForKey:@"ebook"];
			if(eb && [eb ebookNumber] == number){
				return eb;
			}
		}
	}
	return nil;
}



//-- uniqueDictionaryId
// 唯一の辞書IDを作成する
-(NSString*) uniqueDictionaryIdFromPath:(NSString*) path
							  directory:(NSString*) directoryName
{
	NSString* fullpath = [path stringByAppendingPathComponent:directoryName];
	NSString* identifier = [PreferenceModal dictionaryIdForFullPath:fullpath];
	
	identifier = (identifier == nil) ? directoryName : identifier;
	
	int counter = 1;
	id item;
	while((item = [self dictionaryForIdentity:identifier]) != nil){
		if([fullpath isEqualToString:[item valueForKey:@"path"]]){
			return nil;
		}
		identifier = [NSString stringWithFormat:@"%@.%d", directoryName, counter++];
	}
	if(counter > 1){
		[PreferenceModal setDictionaryId:identifier forFullPath:fullpath];
	}
	return identifier;
}


#pragma mark Scan Dictionaries
//-- createDictionaryArray
// 辞書リスト用配列の生成
-(void) createDictionaryArray
{
	NSEnumerator* dictionaies = [[PreferenceModal prefForKey:kDirectoryPath] objectEnumerator];
	
	if(_progressTimer){
		[_progressTimer invalidate];
	}
    
    self.readableAll = YES;
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.00
													  target:self
													selector:@selector(scanDictionary:)
													userInfo:dictionaies
													 repeats:NO];
}


//-- scanDictionary
// 辞書を読み込む
-(void) scanDictionary:(NSTimer*) timer
{
	id obj = [[timer userInfo] nextObject];
	if(obj){
        NSFileManager* fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:obj] == YES && [fm isReadableFileAtPath:obj] == NO){
            if ([PreferenceModal securityBookmarkForPath:obj] == nil){
                self.readableAll = NO;
            }
        }
        [self appendDirectory:obj];
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.00
														  target:self
														selector:@selector(scanDictionary:)
														userInfo:[timer userInfo]
														 repeats:NO];		
	}else{
		_progressTimer = nil;
        [[NSNotificationCenter defaultCenter]
			postNotificationName:kDidInitializeDictionaryManager object:self userInfo:
                [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:[self readableAll]] forKey:kAllDictionariesIsLoaded]];
	}
}


//-- appendDirectory
// 辞書パスの追加
-(void) appendDirectory:(NSString*) path
{
    NSURL* bookmark = [PreferenceModal securityBookmarkForPath:path];
    
    if (bookmark) [bookmark startAccessingSecurityScopedResource];
	NSIndexSet *indexset = [NSIndexSet indexSetWithIndex:[_root count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexset forKey:@"root"];
	DictionaryListItem* item = [DictionaryListItem dictionaryListItemWithPath:path];
	[self expandDirectory:item recursion:YES bookmark:bookmark];
	[_root addObject:item];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexset forKey:@"root"];
    if (bookmark) [bookmark stopAccessingSecurityScopedResource];
}



//-- expandDirectory
// 辞書を展開する
-(void) expandDirectory : (DictionaryListItem*) parent
			  recursion : (BOOL) recursion
               bookmark :(NSURL*) bookmark
{
	NSString* path = [parent valueForKey:@"path"];
	EBook* book = [[EBook alloc] init];
	
	if([book bind:path]){
		[parent setValue:@"book" forKey:@"type"];
		int booknum = [book subbookNum];
		int i;
		for(i=0; i<booknum; i++){
			if([book selectSubbook:i]){
				NSString* dictionaryId = [self uniqueDictionaryIdFromPath:path directory:[book directoryName]];
				if(dictionaryId){
					[book loadPrefFromFile:nil];
                    [book setSecurityScopeBookmark:bookmark];
					EBDictionary* item = [EBDictionary dictionaryListItemWithEBook:book path:path identify:dictionaryId];
					[book release];
					[parent addChild:item];
					[self addDictionary:item];
                    
					book = [[EBook alloc] init];
					[book bind:path];
				}
			}
		}
	}else if(recursion){
		[parent setValue:@"folder" forKey:@"type"];
        
        NSError* error;
		NSArray* fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
		int i;
		for(i=0; i<[fileList count]; i++){
			NSString* new_path = [path stringByAppendingPathComponent:[fileList objectAtIndex:i]];
			BOOL isDirectory;
			if([[NSFileManager defaultManager] fileExistsAtPath:new_path isDirectory:&isDirectory] && isDirectory){
				DictionaryListItem* item = [DictionaryListItem dictionaryListItemWithPath:new_path];
				[self expandDirectory:item recursion:NO bookmark:bookmark];
				[parent addChild:item];
			}
		}
	}
	[book release];
}


//-- removeDirectory
// ディレクトリの消去 返り値は削除したディレクトリのindex
-(NSUInteger) removeDirectory:(DictionaryListItem*) item
{
	NSUInteger index = [_root indexOfObject:item];
	if(index == NSNotFound || index > [_root count]) return NSNotFound;
	
	[self removeDictionaryListItem:item];
	NSIndexSet* indices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index,[_root count] - index)];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"root"];
	// 各ディレクトリの担当辞書の更新
 	[_root removeObjectAtIndex:index];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indices forKey:@"root"];
	return index;
}


//-- removeDictionaryListItem
// directory itemの削除
-(void) removeDictionaryListItem:(DictionaryListItem*) item
{
	NSMutableIndexSet* indeces = [[NSMutableIndexSet alloc] init];
	
	if([item children]){
		NSEnumerator* e =[[item children] objectEnumerator];
		DictionaryListItem* it;
		while(it = [e nextObject]){
			[self removeDictionaryListItem:it];
		}
	}
	if([[item valueForKey:@"type"] isEqualToString:@"dictionary"]){
		NSUInteger index = [_dictionaries indexOfObject:item];
		if(index != NSNotFound){
			[indeces addIndex:index];
		}
	}
	if([indeces count] > 0){
		[self deleteDictionaryAtIndex:indeces];
	}
	[indeces release];
}


#pragma mark Net Dictionaries
//-- createNetDictionaryArray
// ネットワーク辞書の走査
-(void) createNetDictionaryArray
{
	[_netDictionaries release];
	NSArray* files = [[NSBundle mainBundle] pathsForResourcesOfType:@"plist" inDirectory:@"NetDict"];
	_netDictionaries = [[NSMutableArray alloc] initWithCapacity:[files count]];
	
	for(NSString* path in files){
		NSData *data = [NSData dataWithContentsOfFile:path];
		NetDictionary* dict = [NetDictionary netDictionaryWithData:data];
		if(dict){
			[_netDictionaries addObject:dict];
			NSString* directoryName = [[path lastPathComponent] stringByDeletingPathExtension];
			NSString* identify = [self uniqueDictionaryIdFromPath:@"" directory:directoryName];
			[dict setValue:identify forKey:@"id"];
			//[self addDictionary:dict];
		}
	}
}


@end
