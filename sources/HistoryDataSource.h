//	HistoryDataSource.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface HistoryDataSource : NSObject
{
    NSMutableArray* _history;
}

- (BOOL) addHistory : (NSString*) inString;

- (id) comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index;
- (NSInteger) numberOfItemsInComboBox:(NSComboBox *)aComboBox;

@end
