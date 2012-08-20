//	MultiSearchEntry.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MultiSearchViewController;

@interface MultiSearchEntry : NSObject {
	IBOutlet NSView* _view;
	IBOutlet NSTextField*	_entryField;
	IBOutlet NSPopUpButton* _candidatePopUp;
	IBOutlet NSTextField*	_textField;
	
	NSString* _title;
	NSInteger _entry;
	NSArray* _candidates;
	
	id _candidateData;
	MultiSearchViewController* _controller;
}


-(id) init;
-(NSView*) view;
-(void) adjustCandidates;
-(NSMenu*) createCandidatesMenu;
-(NSMenu*) menuFromCandidates:(NSArray*) candidates;

-(id) initWithTitle:(NSString*)title candidates:(NSArray*)candidates;
+(MultiSearchEntry*) entryWithTitle:(NSString*) title candidates:(NSArray*) candidates;
-(void) setController:(MultiSearchViewController*) controller;

-(IBAction) selectCandidate:(id) sender;
-(IBAction) editEntry:(id) sender;

-(NSString*) entryString;
-(id) entryData;

-(NSView*) keyView;
@end
