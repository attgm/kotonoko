//	ContentsHistory.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "ContentsHistory.h"
#import "PreferenceModal.h"

@implementation ContentsHistoryItem
@synthesize url = _url, bitmapCache = _bitmapCache;

#pragma mark constractor
//-- historyItemWithUrl:bitmap:
//
+(ContentsHistoryItem*) historyItemWithUrl:(NSURL*) url
                                    bitmap:(NSBitmapImageRep*) bitmap
{
    return [[[ContentsHistoryItem alloc] initWithUrl:url bitmap:bitmap] autorelease];
}


//-- initWithUrl:bitmap:
//
-(id) initWithUrl:(NSURL*) url
           bitmap:(NSBitmapImageRep*) bitmap
{
    self = [super init];
    if(self){
        _url = [url retain];
        _bitmapCache = [bitmap retain];
    }
    return self;
}

//-- dealloc
//
-(void) dealloc
{
    [_url release];
    [_bitmapCache release];
    [super dealloc];
}

//-- finalize
//
-(void) finalize
{
    [super finalize];
}
@end


@implementation ContentsHistory
@synthesize historyIndex = _historyIndex;
@synthesize currentURL = _currentURL;

#pragma mark constractor
//-- init
// initialize
-(id) init
{
    self = [super init];
    if(self){
        _values = [[[NSMutableArray alloc] init] retain];
        _historyIndex = 0;
    }
    return self;
}


//-- dealloc
// deallocation
-(void) dealloc
{
    [_values release];
    [super dealloc];
}

//-- finalize
// finalization
-(void) finalize
{
    [super finalize];
}


#pragma mark operation
//-- addURL:historyItem:
//
-(void) addURL:(NSURL*)url historyItem:(BOOL)history
{
    if(history){
        [self addHistoryItem:[ContentsHistoryItem historyItemWithUrl:url bitmap:nil]];
    }
    [self setCurrentURL:url];
}


//-- addHistoryItem
// add history item to the history list
-(void) addHistoryItem:(ContentsHistoryItem*) item
{
    [self willChangeValueForKey:@"canBackHistory"];
	[self willChangeValueForKey:@"canForwardHistory"];
	
    NSUInteger count = [_values count];
    if(count > 0 && _historyIndex < (count -1)){
        [_values removeObjectsInRange:NSMakeRange(_historyIndex+1, count - (_historyIndex+1))];
        count = [_values count];
    }
    [_values addObject:item];
    NSUInteger historyMax = [[PreferenceModal prefForKey:kContentHistoryNum] intValue];
    if(historyMax < count){
        [_values removeObjectsInRange:NSMakeRange(0, count - historyMax)];
    }
    _historyIndex = [_values count] - 1;
    
    [self didChangeValueForKey:@"canBackHistory"];
	[self didChangeValueForKey:@"canForwardHistory"];
}


//-- moveHistoryAy
// move history
-(NSURL*) moveHistoryAt:(NSUInteger) index
{
    if (index > [_values count]) return nil;
    [self willChangeValueForKey:@"canBackHistory"];
	[self willChangeValueForKey:@"canForwardHistory"];
    
    NSURL* url = [[_values objectAtIndex:index] url];
	_historyIndex = index;
    
    [self didChangeValueForKey:@"canBackHistory"];
	[self didChangeValueForKey:@"canForwardHistory"];
    
    return url;
}


//-- setCurrentDisplayCache
// set current display cache
-(void) setCurrentDisplayCache:(NSBitmapImageRep*) bitmap
{
    if ([_values count] == 0) return;
    ContentsHistoryItem* item = [_values objectAtIndex:_historyIndex];
    [item setBitmapCache:bitmap];
}


//-- getCurrentDisplayCache
// get current display cache
-(NSBitmapImageRep*) getCurrentDisplayCache:(NSUInteger) offset
{
    if ([_values count] == 0) return nil;
    NSInteger index = _historyIndex + offset;
    
    if (index < 0 || [_values count] < index) return nil;
    return [[_values objectAtIndex:index] bitmapCache];
}

//-- canBackHistory
// can back to page
-(BOOL) canBackHistory
{
	return (_historyIndex > 0);
}


//-- canForwardHistory
// can forward history
-(BOOL) canForwardHistory
{
	return ([_values count] > 0 && _historyIndex < ([_values count] - 1));
}

@end
