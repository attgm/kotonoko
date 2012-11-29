//	ELDefines.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#pragma once
#ifndef __EL_DEFINES_H__
#define __EL_DEFINES_H__

#import <Foundation/Foundation.h>
enum {
	kFileFormat1x = 1,
	kFileFormat2x = 2
};

#define EBDictionaryTagName1xFormat @"DictionaryTagName"
#define EBDictionaryName1xFormat	@"DicName"

typedef struct _EBLocation {
	NSInteger ebook;	// EBook ID
	NSInteger page;	// page
	NSInteger offset; // offset
} EBLocation;

typedef struct _SSize {
    NSInteger		width;
    NSInteger		height;
} SSize;

enum {
    kFontTypeNarrow = 1,
    kFontTypeWide	= 2
};

enum {
    kFontImageSizeLarge,
    kFontImageSizeSmall
};


typedef enum {
	kImageTypeColor,
	kImageTypeMono
} EBImageType;



#define page_NarrowFont 0
#define page_WideFont 1
FOUNDATION_STATIC_INLINE EBLocation EBMakeLocation(NSInteger ebook, NSInteger page, NSInteger offset) {
    EBLocation l;
	l.ebook = ebook;
    l.page = page;
    l.offset = offset;
    return l;
}



FOUNDATION_STATIC_INLINE SSize EBMakeSize(NSInteger width, NSInteger height) {
    SSize s;
    s.width = width;
    s.height = height;
    return s;
}

typedef enum {
	kSearchMethodNone		= -1,
    kSearchMethodWord		= 0,
    kSearchMethodEndWord	= 1,
    kSearchMethodKeyword	= 2,
	kSearchMethodMenu		= 3,
    kSearchMethodSpecific	= 64,
    kSearchMethodMulti		= 256
} ESearchMethod;


#define kMaxBackLocation (5)
#define kMaxCandidate (5)

#define kGaijiFileType @"gaiji"
#define kPlistFileType @"plist"

#define kFinichSearchViewAnimation @"KotonokoFinishSearchAnimation"
#define kHeadingUpdateNotification @"KotonokoHeadingUpdate"
#define kContentAttributeUpdateNotification @"KotonokoContextAttrivuteUpdate"
#define kHeadingAttributeUpdateNotification @"KotonokoHeadingAttrivuteUpdate"
#define kDictionaryChangedNotification	@"KotonokoDictionaryChanged"
#define kFontTableChangedNotification @"KotonokoFontTableChanded"

#ifndef NSAppKitVersionNumber10_2_3
#define NSAppKitVersionNumber10_2_3 663.6
#endif



#endif //__EL_DEFINES_H__