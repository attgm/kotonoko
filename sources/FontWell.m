//	FontWell.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "FontWell.h"

@implementation FontWell

static void *kFontValueBindingIdentifier = (void *) @"FontValue";

#pragma mark IBPalette

//-- valueClassForBinding:
//
- (Class) valueClassForBinding:(NSString *)binding {
	if([binding isEqualToString:@"value"]) {
		return [NSFont class];
	}else{
		return [super valueClassForBinding:binding];
	}
}

//-- dealloc
//
- (void)dealloc
{
	[super dealloc];
}


//-- awakeFromNib
//
- (void)awakeFromNib
{
	[self setTarget:self];
	[self setAction:@selector(_pushed:)];
}

//-- value
//
- (id) value
{
	return _fontwellValue;
}

//-- setValue
//
- (void) setValue : (id) value
{
	if (_fontwellValue) {
		[_fontwellValue release];
	}
	_fontwellValue = (value != nil) ? [value retain] : [[NSFont userFontOfSize:0.0] retain];
	
	[self setTitle:[NSString stringWithFormat:@"%@ - %gpt", [_fontwellValue displayName], [_fontwellValue pointSize]]];
	
	NSFont* resizedFont = [NSFont fontWithName:[_fontwellValue fontName] 
										  size:[[self font] pointSize]];
	[self setFont:resizedFont];
}


//-- changeFont
// 
- (void) changeFont:(id)sender
{
	NSFont* font = [sender convertFont:_fontwellValue];
	[self setValue:font];
	[self updateFontValue:font];
}


//-- active
//
- (void) activate
{
	[[NSFontManager sharedFontManager] setSelectedFont:_fontwellValue isMultiple:NO];
	[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
	[[NSFontPanel sharedFontPanel] setDelegate:self];
	[[self window] makeFirstResponder:self];
}

//-- deactive
//
- (void) deactivate
{
	[self setState:NSOffState];
	if([[NSFontPanel sharedFontPanel] delegate] == self){
		[[NSFontPanel sharedFontPanel] setDelegate:nil];
	}
}

//-- _pushed
- (void)_pushed:(id)sender
{
	int state;
	state = [self state];
	if (state == NSOnState) {
		[self activate];
	}
	if (state == NSOffState) {
		[self deactivate];
	}
}

//-- resignFirstResponder
- (BOOL) resignFirstResponder
{
	[self deactivate];
	return [super resignFirstResponder];
}

#pragma mark FontPanel delegate

- (BOOL)windowShouldClose:(id)sender
{
	[self deactivate];
	return YES;
}


#pragma mark bindings

//-- bind:toObject:withKeyPath:options:
//
- (void)bind:(NSString *)binding
	toObject:(id)observableObject
 withKeyPath:(NSString *)keyPath
	 options:(NSDictionary *)options
{
	if([binding isEqualToString:@"value"]) {
		[self setObservedControllerForValue:observableObject];
		[self setObservedKeyPathForValue:keyPath];
		[self setValueTransformerName:[options objectForKey:@"NSValueTransformerName"]];
		[observableObject addObserver:self
						   forKeyPath:keyPath
							  options:0
							  context:kFontValueBindingIdentifier];
		[self syncValueToController];
	} else {
		[super bind:binding toObject:observableObject withKeyPath:keyPath options:options];
	}
}    

//-- setObservedControllerForValue
//
-(void) setObservedControllerForValue:(id) controller
{
	if (_observedControllerForValue) [_observedControllerForValue release];
	_observedControllerForValue = [controller retain];
}

//-- setObservedKeyPathForValue
//
-(void) setObservedKeyPathForValue:(NSString*) keypath
{
	if (_observedKeyPathForValue) [_observedKeyPathForValue release];
	_observedKeyPathForValue = (keypath != nil) ? [keypath copy] : nil;
}


//-- setValueTransformerName
//
-(void) setValueTransformerName:(NSString*) name
{
	if (_valueTransformerName) [_valueTransformerName release];
	_valueTransformerName =  (name != nil) ? [name copy] : nil;
}


//-- infoForBinding:
//
- (NSDictionary*) infoForBinding:(NSString *) binding
{
	if([binding isEqualToString:@"value"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
			_observedControllerForValue, NSObservedObjectKey,
			_observedKeyPathForValue, NSObservedKeyPathKey, 
			[NSDictionary dictionaryWithObject:_valueTransformerName forKey:@"NSValueTransformerName"], NSOptionsKey,
				nil];
	} else {
		return [super infoForBinding:binding];
	}
}


//-- unbind
// 
- (void)unbind:(NSString *)binding {
	if([binding isEqualToString:@"value"]) {
		[self setObservedControllerForValue:nil];
		[self setObservedKeyPathForValue:nil];
		[self setValueTransformerName:nil];
	} else {
		[super unbind:binding];
	}
}


//-- observeValueForKeyPath:ofObject:change:context:
//
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{	
	if (context == kFontValueBindingIdentifier) {
		[self syncValueToController];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


//-- syncValueToController
-(void) syncValueToController
{
	id font = [_observedControllerForValue valueForKeyPath:_observedKeyPathForValue];
	
	if (_valueTransformerName != nil) {
		NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:_valueTransformerName];
		font = [valueTransformer transformedValue:font];
	}
	[self setValue:font];
}


//-- updateFontValue
//
- (void) updateFontValue:(NSFont*) font
{
	id newValue = font;
	if (_valueTransformerName != nil) {
		NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:_valueTransformerName];
		newValue = [valueTransformer reverseTransformedValue:font]; 
	}
	[_observedControllerForValue setValue:newValue forKeyPath:_observedKeyPathForValue];
}

@end
