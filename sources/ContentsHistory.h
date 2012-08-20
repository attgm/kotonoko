//	ContentsHistory.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//



#import <AppKit/AppKit.h>

@interface ContentsHistoryItem : NSObject
{
    NSURL* _url;
    NSBitmapImageRep* _bitmapCache;
}

+(ContentsHistoryItem*) historyItemWithUrl:(NSURL*)url bitmap:(NSBitmapImageRep*)bitmap;
-(id) initWithUrl:(NSURL*)url bitmap:(NSBitmapImageRep*)bitmap;
-(void) dealloc;
-(void) finalize;

@property(retain) NSURL* url;
@property(retain) NSBitmapImageRep* bitmapCache;


@end


@interface ContentsHistory : NSObject
{
    NSMutableArray* _values;
    NSUInteger _historyIndex;
    NSURL* _currentURL;
}

@property(readonly) NSUInteger historyIndex;
@property(retain) NSURL* currentURL;
@property(readonly) BOOL canBackHistory, canForwardHistory;

-(void) addHistoryItem:(ContentsHistoryItem*)item;
-(void) addURL:(NSURL*)url historyItem:(BOOL)history;
-(NSURL*) moveHistoryAt:(NSUInteger)index;
-(NSURL*) currentURL;
-(void) setCurrentDisplayCache:(NSBitmapImageRep*) bitmap;
-(NSBitmapImageRep*) getCurrentDisplayCache:(NSUInteger) offset;

-(BOOL) canBackHistory;
-(BOOL) canForwardHistory;

@end
