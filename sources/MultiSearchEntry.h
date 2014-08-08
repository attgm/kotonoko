//	MultiSearchEntry.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MultiSearchViewController;

@interface MultiSearchEntry : NSViewController {
	IBOutlet NSTextField*	_entryField;
	IBOutlet NSPopUpButton* _candidatePopUp;
	IBOutlet NSTextField*	_textField;
    
    NSInteger _entry;
	NSArray* _candidates;
	
	id _candidateData;
	MultiSearchViewController* _controller;
}

@property (retain, nonatomic) NSString* label;

-(id) init;
-(void) adjustCandidates;
-(NSMenu*) createCandidatesMenu;
-(NSMenu*) menuFromCandidates:(NSArray*) candidates;

-(id) initWithLabel:(NSString*)label candidates:(NSArray*)candidates;
+(MultiSearchEntry*) entryWithLabel:(NSString*) title candidates:(NSArray*) candidates;
-(void) setController:(MultiSearchViewController*) controller;

-(IBAction) selectCandidate:(id) sender;
-(IBAction) editEntry:(id) sender;

-(NSString*) entryString;
-(id) entryData;

-(NSView*) keyView;
@end
