//	CandidateContainer.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import "CandidateContainer.h"


@implementation CandidateGroup
//-- initWithString:location:
// 初期化
-(id) initWithString:(NSAttributedString*)string
			location:(EBLocation)location
{
	self = [super init];
    if(self){
        _string = [string copyWithZone:nil];
        _location = location;
    }
	return self;
}


//-- candidateWithString:location:
// 
+(id) candidateWithString:(NSAttributedString*)string
				 location:(EBLocation)location
{
	return [[CandidateGroup alloc] initWithString:string location:location];
}


//-- string
// 文字列を返す
-(NSAttributedString*) attributedString
{
	return _string;
}


//-- location
// グループの位置を返す
-(EBLocation) location
{
	return _location;
}

@end


@implementation CandidateLeaf
//-- initWithString
// Leaf candidateの初期化
-(id) initWithString:(NSAttributedString*)string
		   candidate:(NSData*)candidate
{
	self = [super init];
    if(self){
        _string = [string copyWithZone:nil];
        _candidate = [candidate copyWithZone:nil];
    }
	return self;
}


//-- candidateWithString:location:
// 
+(id) candidateWithString:(NSAttributedString*)string
				candidate:(NSData*)candidate
{
	return [[CandidateLeaf alloc] initWithString:string candidate:candidate];
}


//-- dealloc
// 後片付け


//-- string
// 文字列
-(NSAttributedString*) attributedString
{
	return _string;
}


//-- candidate
// 検索用文字列
-(NSData*) candidate
{
	return _candidate;
}

@end


#pragma mark -

@implementation CandidateContainer

//-- initWithEBook:attribute:
// 初期化
-(id)initWithEBook:(EBook*)inBook
{
	self = [super initWithEBook:inBook];
    if(self){
        _candidates = [[NSMutableArray alloc] init];
        _data = [[NSMutableData alloc] initWithCapacity:32];
	}
    return self;
}


//-- dealloc
// 後片付け


//-- candidates
// candidateを返す
-(NSArray*) candidates
{
	return _candidates;
}


//-- beginCandidate
// candidateの開始
-(void) beginCandidate
{
	[_string deleteCharactersInRange:NSMakeRange(0, [_string length])];
	[_data setLength:0];
}


//-- endGroupCandidate
// candidate
-(void) endGroupCandidate:(EBLocation) location
{
	[_candidates addObject:[CandidateGroup candidateWithString:_string location:location]];
}


//-- endLeafCandidate
// 末端のcandidateの終わり
-(void) endLeafCandidate
{
	[_data appendBytes:"\0" length:1];
	[_candidates addObject:[CandidateLeaf candidateWithString:_string candidate:_data]];
}


//-- addCharacter 
// caracterを追加する
-(void) appendBytes:(const void *)bytes length:(NSUInteger)length 
{
	[_data appendBytes:bytes length:length];
}


@end
