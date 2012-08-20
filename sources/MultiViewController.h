//	MultiViewController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ELDefines.h"

@class EBookController;

@interface MultiViewController : NSObject
{
    IBOutlet NSComboBox *mCandidate_0;
    IBOutlet NSComboBox *mCandidate_1;
    IBOutlet NSComboBox *mCandidate_2;
    IBOutlet NSComboBox *mCandidate_3;
    IBOutlet NSComboBox *mCandidate_4;
    IBOutlet NSTextField *mLabelText_0;
    IBOutlet NSTextField *mLabelText_1;
    IBOutlet NSTextField *mLabelText_2;
    IBOutlet NSTextField *mLabelText_3;
    IBOutlet NSTextField *mLabelText_4;
    IBOutlet NSView *mCandidatesView;
    IBOutlet NSPopUpButton *mMethodPopup;
    
    NSArray* mCandidates[kMaxCandidate];
    NSComboBox *mComboBoxArray[kMaxCandidate];
    NSTextField *mTextFieldArray[kMaxCandidate];

    EBookController *mEBookController;
    int mActiveSearchNumber;
}

- (IBAction) selectSearch:(id)sender;
- (IBAction) changeEntry:(id)sender;


- (id) initWithController : (EBookController*) inController;

- (void) createMultiSearchView;
- (NSView*) candidatesView;
- (void) setCandidate : (NSArray*) inCandidates
		entry : (NSString*) inString
		   at : (int) inIndex
		clear : (BOOL) inClearValue;

- (void) nextCandidate : (int) inIndex
		 entry : (NSString*) inEntry
		    at : (int) inSelected;

- (id)               comboBox : (NSComboBox *) aComboBox
    objectValueForItemAtIndex : (int) index;
- (int) numberOfItemsInComboBox : (NSComboBox *) aComboBox;
@end
