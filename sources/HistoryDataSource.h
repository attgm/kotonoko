//	HistoryDataSource.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface HistoryDataSource : NSObject
{
    NSMutableArray* _history;
}

- (BOOL) addHistory : (NSString*) inString;

- (id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index;
- (int) numberOfItemsInComboBox:(NSComboBox *)aComboBox;

@end
