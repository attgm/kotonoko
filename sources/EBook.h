//	EBook.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <eb/eb.h>
#import <eb/text.h>
#import <eb/appendix.h>

#import "ELDefines.h"

extern NSString *const EBContentsConinuity;
extern NSString *const EBShowGaijiCode;
extern NSString *const EBFontImageHeight;
extern NSString *const EBSuperScriptAttributes;
extern NSString *const EBSubScriptAttributes;
extern NSString *const EBKeywordAttributes;
extern NSString *const EBGaijiAttributes;
extern NSString *const EBEmphasisAttributes;
extern NSString *const EBTextAttributes;
extern NSString *const EBReferenceTextColor;
extern NSString *const EBTagAttributes;

@class FontTableElement;

@interface EBook : NSObject {
    EB_Book			_book;
    EB_Appendix		_appendix;
    EB_Hookset		_textHookset;
    EB_Hookset		_headingHookset;
    EB_Hookset		_candidatesHookset;
    EB_Hookset		_htmlHookset;
	
    int                 _subbookNum;
    EB_Subbook_Code     _subbook[EB_MAX_SUBBOOKS];
    int                 _activeSubbook;
    
    EB_Multi_Search_Code    _multiCode[EB_MAX_MULTI_SEARCHES];
    int                     _multiCodeNum;
    
    NSMutableDictionary*    _narrowFontDic;
    NSMutableDictionary*    _wideFontDic;

    NSString*       _tagName;
    NSUInteger      _ebookNumber; // ID
	
    EB_Font_Code    _smallFontType;
    EB_Font_Code    _largeFontType;
	
	BOOL    _hasSerialContents;
};

@property (retain) NSString* tagName;
@property (assign,readonly) NSUInteger ebookNumber;


+ (void) initalizeLibrary : (BOOL) inInit;

- (id) init;
- (void) dealloc;
- (void) finalize;
- (BOOL) bind : (NSString*) inPath;
- (void) closeBook;
- (BOOL) bindAppendix : (NSString*) inPath;
- (BOOL) selectSubbook : (int) inIndex;
- (int) subbookNum;
- (NSString*) stringSubbookTitle;

- (BOOL) haveSearchMethod : (ESearchMethod) inMethod;
- (NSArray*) search:(NSString*)word method:(ESearchMethod)method max:(int)maxHits paramator:(NSDictionary*)paramator;
- (EB_Error_Code) searchKeyword : (char*) inWord
                         length : (int) inLength;
- (BOOL) isDuplicate:(EBLocation)losition at:(NSArray*)array;

- (NSAttributedString*) copyrightWithParamator:(NSDictionary*) paramator;
- (NSString*) directoryName;

- (NSImage*) imageAt:(EBLocation)inLocate type:(EBImageType)inStyle size:(SSize)inSize;
- (NSData*) movieByName : (NSString*) inPath;
- (NSString*) moviePath : (NSString*) inPath;
- (NSData*) soundWithPath:(NSString*) path;
// Font
- (NSArray*) fontTable:(int) inKind;
- (FontTableElement*) fontTableElementWithCode:(int)code kind:(int)kind;

- (void) setFontSize;
- (NSImage*) fontImageWithCode:(int)inCode kind:(int)inKind size:(int)inSize;
- (NSImage*) fontImageWithCode:(int)code kind:(int)kind size:(int)size color:(NSColor*)color;

- (NSString*) stringWithCode:(int)inCode 
						kind:(int)inKind;
- (void) setStringWithCode:(int)inCode
					  kind:(int)inKind
					string:(NSString*)inString;
-(BOOL) useAlternativeWithCode:(int)code kind:(int)kind;
-(void) setUseAlternative:(BOOL)use code:(int)code kind:(int)kind;
-(void) setAlternativeString:(NSString*)alternative use:(BOOL)use code:(int)code kind:(int)kind;

- (void) createFontTableWithProparty:(NSDictionary*)proparty kind:(int)kind;
- (void) createFontTableAll;

-(NSArray*) arrayMultiSearchTitle;
-(NSArray*) arrayMultiSearchEntry:(int)inIndex;
-(NSArray*) arrayMultiSearchCandidates:(int)inIndex  at:(int)inEntryID;
-(NSArray*) arrayMultiSearchCandidatesWithLocation:(EBLocation)inIndex;
-(NSArray*) multiSearch:(NSArray*)entries index:(NSInteger)index max:(int)maxHits paramator:(NSDictionary*)paramator;

-(NSAttributedString*) stringHeading:(EB_Position*)inPosition paramator:(NSDictionary*)code;
-(NSAttributedString*) contentAt:(EBLocation)inLocation paramator:(NSDictionary*)code;
-(NSString*) htmlContentAt:(EBLocation) location;
-(BOOL) forwardContent;
-(NSAttributedString*) readTextWithParamator:(NSDictionary*) paramator;

-(NSString*) propertyPath;
-(NSString*) oldPropertyPath;
-(NSString*) bandledPropertyPath;
-(void) savePrefToFile:(NSString*) inPath format:(NSInteger) format;
-(void) loadPrefFromFile:(NSString*) inPath;
-(void) convert1xPropertyWithPath:(NSString*) path;
-(void) save1xPropertyToFile:(NSString*) path;

-(BOOL) haveMenu;
-(NSAttributedString*) menuWithParamator:(NSDictionary*) paramator;
-(BOOL) hasSerialContents:(EBLocation*) location;
-(BOOL) hasBackwordContents:(EBLocation*) location;
@end
