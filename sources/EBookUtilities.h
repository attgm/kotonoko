//	EBookUtilities.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <Cocoa/Cocoa.h>

extern NSImage* MakeFontDataFromPath(NSString* path, int size);
extern void SetFontAlternativeString(NSString* path, NSString* alternative);
extern void SetFontUseAlternativeString(NSString* path, BOOL alternative);
extern NSString* MakeApplicationSupportFolder(void);
extern NSString* MakeHtmlFolder(void);
extern NSString* MakeGaijiFolder(void);
extern BOOL IsAppSandboxed(void);
