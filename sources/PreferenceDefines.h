//	PreferenceDefines.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#define kContentsConinuity @"contentsConinuity"
#define kContentsColor @"contentsColor"
#define kHeadingColor @"headingColor"
#define kLinkColor @"linkColor"
#define kLinkUnderLine @"linkUnderLine"
#define kIndexColor @"indexColor"
#define kScanVolume @"ScanVolume"
#define kDirectoryPath @"Dictionaries"
#define kAppendixPath @"Appendix"
#define kHeadingFont @"headingFont"
#define kContentsFont @"contentsFont"
#define kCurrentDictionary @"currentDictionary"
#define kFindColor @"findColor"
#define kWindowStyle @"windowStyle"
#define kWSSwitchingWidth @"windowStyleSwitchingWidth"
#define kQuitWhenNoWindow @"quitWhenNoWindow"
#define kUseSmallWindow @"useSmallWindow"
#define kDiminishRescan @"deminichRescan"
#define kSearchAllMax @"searchAllMax"
#define kDictionaryNameColor @"dictionaryNameColor"
#define kDictionaryBackgroundColor @"dictionaryBackgroundColor"
#define kShowOnlyEBookSet @"ShowOnlyEBookSet"
#define kEBookSetTitle @"title"
#define kEBookSetList @"dictionaries"
#define kEBookSet @"ebookSet"
#define kPlaySoundAutomatically @"playSoundAutomatically"
#define kDictionaryTable @"dictionaryTable"
#define kDictionaryIdTable @"dictionaryIdTable"
#define kAppendixTable @"appendixTable"
#define kQuickTabTable @"quickTag"
#define kQuickTabFont @"quickTagFont"
#define kMemberOfQuickTab	@"member"
#define kContentHistoryNum @"contentHistoryNum"
#define kUsePasteboardSearch @"pasteboardSearch"
#define kUseBackgroundPastebordSearch @"backgroundPasteboardSearch"
#define kAutoFowardingContents @"autoFowardingContents"
#define kContentsCharactersMax @"contentsCharacterMax"
#define kFitWebViewScale @"fitWebViewScale"
#define kSwipeBehavior @"swipeBehavior"
#define kSecureBookmarkTable @"secureBookmarks"

typedef enum {
    kFitScaleOff                    = 1000,
    kFitScaleWhenSmartZoom          = 1001,
    kFitScaleWhenLoaded             = 1002
} FitWebViewScale;


typedef enum {
    kSwipeBehaviorOff               = 1000,
    kSwipeBehaviorSwitchPage        = 1001,
    kSwipeBehaviorSwitchDictionary  = 1002
} SwipeBehavior;


typedef enum {
	kWindowStyleHorizontal = 1001,
	kWindowStyleVertical   = 1002,
	kWindowStyleAutomatic  = 1003
} WindowStyle;

#define kTagEBook @"ebook"
#define kTagNetworkDictionary @"network"
#define kTagBookSet @"bookset"
#define kTagFontAndColor @"fontandcolor"
#define kTagView @"view"
#define kTagEtc @"etc"
#define kTagQuickTab @"tag"
