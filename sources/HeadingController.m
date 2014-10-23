//	HeadingController.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "HeadingController.h"
#import "PreferenceModal.h"
#import "DictionaryElement.h"


@implementation HeadingController

#pragma mark Delegate:NSTableView
//-- tableView:shouldSelectRow
// table viewが選択された時の処理
- (BOOL)	tableView : (NSTableView*) tableView
	  shouldSelectRow : (int) rowIndex
{
	if(rowIndex >=0 && rowIndex < [tableView numberOfRows]){
		if([[[self arrangedObjects] objectAtIndex:rowIndex] canSelect]){
			return YES;
		}
    }
    return NO;
}



//-- tableView:willDisplayCell:forTableColumn:row:
// テーブルviewの背景を指定
-(void)			tableView:(NSTableView *) tableView
		  willDisplayCell:(id) cell
		   forTableColumn:(NSTableColumn *) tableColumn
					  row:(int) row
{
	if([[[self arrangedObjects] objectAtIndex:row] canSelect]){
		[cell setDrawsBackground:NO];
		//[cell setFont:[PreferenceModal fontForKey:kHeadingFont]];
		//[cell setTextColor:[PreferenceModal colorForKey:kHeadingColor]];
		[cell setAlignment:NSNaturalTextAlignment];
	}else{
        [cell setDrawsBackground:NO];
		//[cell setBackgroundColor:[PreferenceModal colorForKey:kDictionaryBackgroundColor]];
        //[cell setFont:[[NSFontManager sharedFontManager] 
        //  convertFont:[PreferenceModal fontForKey:st] toHaveTrait:NSBoldFontMask]];
		//[cell setTextColor:[PreferenceModal colorForKey:kDictionaryNameColor]];
		[cell setAlignment:NSCenterTextAlignment];
		[cell setBordered:NO];
	}

}


//-- tableView:isGroupView
//
-(BOOL)     tableView:(NSTableView*) tableView
           isGroupRow:(NSInteger)row
{
    return [[[self arrangedObjects] objectAtIndex:row] canSelect] ? NO : YES;
}


//-- viewForTableColumn:row
//
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    DictionaryElement* entity = [self.arrangedObjects objectAtIndex:row];
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:([entity canSelect] ? @"TextCell" : @"GroupCell")
                                                                owner:self];
    [cellView.textField setAttributedStringValue:entity.attributedString];
    return cellView;
}    


@end


              