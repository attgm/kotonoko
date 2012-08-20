//	EBookCatalog.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBookCatalog : NSObject {
	NSString* mLabelTitle;
	NSString* mPermanentTitle;
	NSMutableArray* mEBookList;
}

//-(id) initWithTitle:(NSString*) inPermanentTitle tag:(NSString*)inLabelTitle;
//-(void) addEBookWithPath:(NSString*)inPath subbook:(int)inSubbookID;

@end
