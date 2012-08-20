//	PreferenceModal.h
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferenceDefines.h"

@interface PreferenceModal : NSObject {
 	NSMutableDictionary*	_preferences;
}

+(PreferenceModal*) sharedPreference;
+(id) prefForKey:(NSString*) key;
+(NSColor*) colorForKey:(NSString*) key;
+(NSFont*) fontForKey:(NSString*) key;
+(NSMutableDictionary*) dictioanryPreferenceForId:(NSString*) identifier;
+(NSString*) dictionaryIdForFullPath:(NSString*) path;
+(void) setDictionaryId:(NSString*) identifier forFullPath:(NSString*) fullPath;

-(id) init;
-(void) dealloc;

-(void) setValue:(id) value forKey:(NSString*) key;
-(id) valueForKey:(NSString*) key;

-(void) preferencesFromDefaults;
-(void) savePreferencesToDefaults;
-(NSMutableArray*) mutableArrayFromArray:(NSArray*) array;
-(NSMutableDictionary*) mutableDictionaryFromDictionary:(NSDictionary*) dic;

@end
