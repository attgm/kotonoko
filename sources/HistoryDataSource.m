//	HistoryDataSource.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "HistoryDataSource.h"

@implementation HistoryDataSource


//-- awakeFromNib
- (void) awakeFromNib
{
    _history = [[NSMutableArray alloc] initWithCapacity:10];
}


//-- dealloc
- (void) dealloc
{
    [_history release];
	[super dealloc];
}


//-- addHistory
- (BOOL) addHistory : (NSString*) inString
{
    NSEnumerator* e = [_history objectEnumerator];
    id obj;
	
	// もしすでに入っている要素だったらHistoryに加えない
    while(obj = [e nextObject]){
		if ([inString isEqualToString:obj] == YES){
			return NO;
		}
    }
    
    // 先頭にHistoryを挿入する
    [_history insertObject:inString atIndex:0];
    // 10個以上のHistoryを消去
    while([_history count] > 10){
		[_history removeLastObject];
    }

    return YES;
}


//-- comboBox:objectValueForItemAtIndex: (protcol : NSComboBoxDataSource)
// Historyエントリを返す
- (id)               comboBox : (NSComboBox *) aComboBox
    objectValueForItemAtIndex : (int) index
{
    return [_history objectAtIndex:index];
}


//-- numberOfItemsInComboBox: (protcol : NSComboBoxDataSource)
- (NSInteger) numberOfItemsInComboBox : (NSComboBox *) aComboBox
{
    return [_history count];
}

@end
