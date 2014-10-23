//	FontPanelController.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

@class EBookController;
//@class EBookSet;
@class EBook;
@class FontTableElement;
@class ACBindingItem;

extern NSString* const EBFontPanelDictionaryIdentifier;

@interface FontPanelController : NSWindowController
{
    IBOutlet NSImageView*	_imageView;
	IBOutlet NSTextField*	_identifyField;
	IBOutlet NSTextField*	_stringField;
	IBOutlet NSMatrix*		_matrixView;
	
	IBOutlet NSView*		_accessoryView;
	IBOutlet NSPopUpButton*	_formatPopup;
	IBOutlet NSArrayController* _arrayController;

	FontTableElement* _currentElement;
	
	EBook*	mCurrentEBook;
	
	NSInteger _currentBinder;
	int _fontKind;
	NSArray* _fontsArray;
	
	NSSavePanel* _panel;
	NSIndexSet*	_selectedFonts;
	
	ACBindingItem* _bindingItem;
}


- (IBAction)exportFontTable:(id)sender;
- (IBAction)importFontTable:(id)sender;
- (IBAction) changeExportFileFormat:(id) sender;

- (id) init;
- (void) dealloc;

- (void) showFontPanel;
//- (void) sheetDidEnd:(NSWindow *)inSheet returnCode:(int)inReturnCode contextInfo:(void *)inContextInfo;
-(NSArray*) fontsArray;
-(void) setFontsArray:(NSArray*) fonts;

-(ACBindingItem*) bindingItem;
-(Class) valueClassForBinding:(NSString *)binding;
-(void) bind:(NSString *)binding toObject:(id)observableObject withKeyPath:(NSString *)keyPath options:(NSDictionary *) options;
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
-(NSDictionary*) infoForBinding:(NSString *) binding;
-(void) unbind:(NSString *) binding;


-(void) observeDictionary:(ACBindingItem*) item;

@end
