//	EBookUtilities.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

NSImage* MakeFontDataFromPath(NSString* path, int size);
void SetFontAlternativeString(NSString* path, NSString* alternative);
void SetFontUseAlternativeString(NSString* path, BOOL alternative);
NSString* MakeApplicationSupportFolder(void);
NSString* MakeHtmlFolder(void);
NSString* MakeGaijiFolder(void);