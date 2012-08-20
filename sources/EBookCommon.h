//	EBookCommon.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <eb/eb.h>

enum { kEbNarrowFont, kEbWideFont };
enum { kEbLargeFont, kEbSmallFont };
typedef enum { kColorImageTye, kImageTypeMono } EBImageType;

@interface EBookCommon : NSObject {
	EB_Book	mBook;
	EB_Appendix	mAppendix;
	
	int				mSubbookNum;
	EB_Subbook_Code	mSubbook[EB_MAX_SUBBOOKS];
	int				mActiveSubbook;
	
    NSMutableDictionary*	mNarrowFontDic;
    NSMutableDictionary*	mWideFontDic;

	NSString* mTagName;
    int mEBookNumber; // ID
	
    EB_Font_Code mSmallFontType;
    EB_Font_Code mLargeFontType;
}

+(void) initalizeLibrary : (BOOL) inInit;
-(id) init;
-(void) closeBook;
-(BOOL) bind:(NSString*) inPath;

-(BOOL) selectSubbook : (int) inIndex;
-(int) subbookNum;
-(NSString*) stringSubbookTitle;
-(NSString*) directoryName;
-(void) setTagName:(NSString*)inTagName;
-(NSString*) tagName;

- (NSString*) readText:(EB_Position) inLocation;

-(NSString*) preferencePath;
-(void) loadPreferenceFromPath:(NSString*) inPath;
@end
