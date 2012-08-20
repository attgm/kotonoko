//	MultiViewController.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import "MultiViewController.h"
#import "DictionaryElement.h"
#import "EBookController.h"

@implementation MultiViewController

//-- initWithController
- (id) initWithController : (EBookController*) inController
{
    int i;
    [super init];

    mEBookController = [inController retain];
    for(i=0; i<kMaxCandidate; i++){
	mCandidates[i] = nil;
    }

    return self;
}


//-- dealloc
- (void) dealloc
{
    int i;
    
    [mEBookController release];
    for(i=0; i<kMaxCandidate; i++){
	[mCandidates[i] release];
    }
}


//-- createMultiSearchView
//
- (void) createMultiSearchView
{
    if (![NSBundle loadNibNamed:@"MultiSeachInput" owner:self])  {
	NSLog(@"Failed to load MultiSearchInput.nib");
	NSBeep();
	return;
    }

    mComboBoxArray[0] = mCandidate_0;
    mComboBoxArray[1] = mCandidate_1;
    mComboBoxArray[2] = mCandidate_2;
    mComboBoxArray[3] = mCandidate_3;
    mComboBoxArray[4] = mCandidate_4;
    mTextFieldArray[0] = mLabelText_0;
    mTextFieldArray[1] = mLabelText_1;
    mTextFieldArray[2] = mLabelText_2;
    mTextFieldArray[3] = mLabelText_3;
    mTextFieldArray[4] = mLabelText_4;
}


//-- candidatesView
// viewを返す
- (NSView*) candidatesView
{
    if(!mCandidatesView)
	[self createMultiSearchView];
    return mCandidatesView;
}


//-- setCandidate
// 見出し候補を設定する
- (void) setCandidate : (NSArray*) inCandidates
		entry : (NSString*) inString
		   at : (int) inIndex
		clear : (BOOL) inClearValue
{
    [mCandidates[inIndex] release];
    mCandidates[inIndex] = [[NSArray alloc] initWithArray:inCandidates];
    if([inCandidates count] > 10){
	[mComboBoxArray[inIndex] setNumberOfVisibleItems:10];
    }else{
	[mComboBoxArray[inIndex] setNumberOfVisibleItems:[inCandidates count]];
    }
    if(inClearValue == YES){
	[mComboBoxArray[inIndex] setStringValue:@""];
    }
    [mComboBoxArray[inIndex] reloadData];

    [mTextFieldArray[inIndex] setStringValue:inString];

    if(![inString isEqualToString:@""]){
	[mComboBoxArray[inIndex] setEnabled:YES];
	[mTextFieldArray[inIndex] setEnabled:YES];
    }else{
	[mComboBoxArray[inIndex] setEnabled:NO];
	[mTextFieldArray[inIndex] setEnabled:NO];
    }
}


//-- selectSearch
// 複合検索の切替
- (IBAction) selectSearch : (id)sender
{
    mActiveSearchNumber = [sender tag];
    [mEBookController changeMultiSearchMethod:[sender tag]];
}


#pragma mark -
//-- changeEntry
// menuが選択された時の処理
- (IBAction) changeEntry : (id)sender
{
    int tag = [sender tag];
    NSString* entry = [mComboBoxArray[tag] stringValue];
    int selected = [mComboBoxArray[tag] indexOfSelectedItem];

    if (selected >= 0){
	[self nextCandidate:tag entry:entry at:selected];
    }
}


//-- nextCandidateTo
// 見出し語のレベルを1つ下げる
- (void) nextCandidate : (int) inIndex
		 entry : (NSString*) inEntry
		    at : (int) inSelected
{
    NSArray* array;
    id obj = [mCandidates[inIndex] objectAtIndex:inSelected];
    if([obj page] < 0){ // leaf nodeの場合そのまま
	NSString* label = [mEBookController stringEntryLabelByID:inIndex
						    searchNumber:mActiveSearchNumber];
	array = [mEBookController arrayCandidateWithEntryID:inIndex searchNumber:mActiveSearchNumber];
	[self setCandidate:array entry:label at:inIndex clear:NO];
    }else{
	array = [mEBookController arrayCandidateWithLocation:
	    EBMakeLocation([obj page], [obj offset])];
	[self setCandidate:array entry:inEntry at:inIndex clear:YES];
    }
}


#pragma mark -
//-- comboBox:objectValueForItemAtIndex: (protcol : NSComboBoxDataSource)
// エントリを返す
- (id)               comboBox : (NSComboBox *) aComboBox
    objectValueForItemAtIndex : (int) index
{
    int tag = [aComboBox tag];
    return [[mCandidates[tag] objectAtIndex:index] stringHeading];
}



//-- numberOfItemsInComboBox: (protcol : NSComboBoxDataSource)
- (int) numberOfItemsInComboBox : (NSComboBox *) aComboBox
{
    int tag = [aComboBox tag];
    return [mCandidates[tag] count];
}

@end
