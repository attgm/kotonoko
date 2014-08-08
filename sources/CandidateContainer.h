//	CandidateContainer.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "ELDefines.h"
#import "EBookContainer.h"

@interface CandidateGroup : NSObject {
	NSAttributedString* _string;
	EBLocation			_location;
}

-(id) initWithString:(NSAttributedString*)string location:(EBLocation)location;
+(id) candidateWithString:(NSAttributedString*)string location:(EBLocation)location;
-(void) dealloc;

-(NSAttributedString*) attributedString;
-(EBLocation) location;
@end


@interface CandidateLeaf : NSObject {
	NSAttributedString* _string;
	NSData*				_candidate;
}

-(id) initWithString:(NSAttributedString*)string candidate:(NSData*)candidate;
+(id) candidateWithString:(NSAttributedString*)string candidate:(NSData*)candidate;
-(void) dealloc;

-(NSAttributedString*) attributedString;
-(NSData*) candidate;
@end


@interface CandidateContainer : EBookContainer {
	NSMutableArray* _candidates;
	NSMutableData*	_data;
}

-(id)initWithEBook:(EBook*)inBook;
-(void)dealloc;

-(NSArray*) candidates;
-(void) beginCandidate;
-(void) endGroupCandidate:(EBLocation) inLocation;
-(void) endLeafCandidate;

-(void) appendBytes:(const void *)bytes length:(NSUInteger)length;

@end
