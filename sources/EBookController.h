//	EBookController.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//
// * service method added by Hiroshi TOMIE 2002-03-15


#import <Cocoa/Cocoa.h>
#import "ELDefines.h"

@class HistoryDataSource;
@class EBook;
@class InputPanelController;
@class MultiViewController;
@class WindowController;

@class FontPanelController;
@class DictionaryBinderManager;
@class DictionaryBinder;
@class ACMenuBinder;
@class PasteboardWatcher;
@class AcknowledgmentsWindowController;

@interface EBookController : NSObject <NSApplicationDelegate>
{
	IBOutlet ACMenuBinder* _dictionaryMenuBinder;
	
	DictionaryBinderManager* _binderManager;
	DictionaryBinder* _currentDictionaryBinder;
	NSArrayController*	_dictionaryController;
	
    //EBLocation mGaijiLocation;
	BOOL _hasVolumes;
    
	FontPanelController* _fontPanelController;

    WindowController* _windowController;	
	PasteboardWatcher* _pasteboardWatcher;
    AcknowledgmentsWindowController* _acknowledgmentsWindowController;
}


- (IBAction)newSearch:(id)sender;
- (IBAction)print:(id)sender;
- (IBAction)rescanDictionary:(id)sender;
- (IBAction)runPageLayout:(id)sender;
- (IBAction)showFontTable:(id)sender;
- (NSString*) dictionaryName;
- (IBAction) showPreferencePanel:(id)sender;

- (void) applicationWillTerminate : (NSNotification *) aNotification;
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void) rescanDictionary;
- (void) showCopyright;
//- (void) changeDictionaryAt:(int) inIndex;
- (ESearchMethod) methodByTag : (int) inTag;
- (void) selectDictionary: (int) inIndex;
-(EBLocation) locationFromURL:(NSURL*) url;

// service method added by Hiroshi TOMIE 2002-03-15
- (void)doLookupService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

- (void) didMountUnmount : (NSNotification*) inNote;
- (void) willUnmount : (NSNotification*) inNote;
- (void) clearAllDictionaries;

//- (void) searchWord:(NSString*)inWord completely:(BOOL)inAll;
- (void) searchAndPasteWord:(NSString*)inWord;
//- (void) searchWord:(NSString*)inWord method:(ESearchMethod)inMethod max:(int)inMaxNumber;

- (BOOL) haveSearchMethodByTag : (int) inTag;


//-(DictionaryBinder*) currentDictionaryBinder;
//-(void) setCurrentDictionaryBinder:(DictionaryBinder*) binder;

-(WindowController*) windowController;
-(void) setWindowController:(WindowController*) controller;

-(void) searchPasteboardString;

@end
