//	EBookUtilities.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "DictionaryManager.h"
#import "EBook.h"
#import "EBookUtilities.h"

NSString* const EBApplicationName = @"Kotonoko";

//-- MakeFontDataFromPath
// パスからフォントデータを取得する
NSImage* MakeFontDataFromPath(NSString* path, int size)
{

	NSArray* paths = [path pathComponents];
	
	if([paths count] > 3){
		int ebookNumber = [[paths objectAtIndex:1] intValue];
		int type =  [[paths objectAtIndex:2] isEqualToString:@"w"] ? kFontTypeWide : kFontTypeNarrow;
		int code = [[paths objectAtIndex:3] intValue];
		
		EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:ebookNumber];
		
		NSColor* blackColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
		return [eb fontImageWithCode:code kind:type size:size color:blackColor];
	}
	return nil;
}


//-- SetFontAlternativeString
// 代替文字を設定する
void SetFontAlternativeString(NSString* path, NSString* alternative)
{	
	NSArray* paths = [path pathComponents];
	
	if([paths count] > 3){
		int ebookNumber = [[paths objectAtIndex:1] intValue];
		int type =  [[paths objectAtIndex:2] isEqualToString:@"w"] ? kFontTypeWide : kFontTypeNarrow;
		int code = [[paths objectAtIndex:3] intValue];
		
		EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:ebookNumber];
		
		[eb setStringWithCode:code kind:type string:alternative];
		[eb savePrefToFile:nil format:kFileFormat2x];
	}
}


//-- SetFontUseAlternativeString
// alternative stringを使うかどうかの設定 
void SetFontUseAlternativeString(NSString* path, BOOL alternative)
{	
	NSArray* paths = [path pathComponents];
	
	if([paths count] > 3){
		int ebookNumber = [[paths objectAtIndex:1] intValue];
		int type =  [[paths objectAtIndex:2] isEqualToString:@"w"] ? kFontTypeWide : kFontTypeNarrow;
		int code = [[paths objectAtIndex:3] intValue];
		
		EBook* eb = [[DictionaryManager sharedDictionaryManager] ebookForEBookNumber:ebookNumber];
		
		[eb setUseAlternative:alternative code:code kind:type];
		[eb savePrefToFile:nil format:kFileFormat2x];
	}
}


//-- MakeApplicationSupportFolder
// Application Supportフォルダの生成
NSString* MakeApplicationSupportFolder(void)
{
	NSFileManager* fm = [NSFileManager defaultManager];
    
	NSArray* libraryPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);    
	NSString* libraryPath = ([libraryPaths count] > 0) ? [libraryPaths objectAtIndex:0] : nil;
    
    if (!libraryPath || ![fm fileExistsAtPath:libraryPath]) {
        NSLog(@"Could not find applicaiton support directory");
        return nil;
    }
    
    NSString*   path = [libraryPath stringByAppendingPathComponent:EBApplicationName];
    if (![fm fileExistsAtPath:path]) {
        NSError* error;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return path;
}


//-- MakeHtmlFolder
// html フォルダの生成
NSString* MakeHtmlFolder(void)
{
	static BOOL isInitializeHtml = NO;
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* path = MakeApplicationSupportFolder();
	path = [path stringByAppendingPathComponent:@"html"];
	if(!isInitializeHtml){
        NSError* error;
		if([fm fileExistsAtPath:path]){
			if(![fm removeItemAtPath:path error:&error]){
				NSLog(@"Could not remove path:%@", path);
			}
		}
		NSString* srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"template"];
		if(![fm copyItemAtPath:srcPath toPath:path error:&error]){
			NSLog(@"Could not copy %@ to %@", srcPath, path);
		}
		isInitializeHtml = YES;
    }

	return path;
}


//-- MakeGaijiFolder
// font フォルダの生成
NSString* MakeGaijiFolder(void)
{
	NSFileManager* fm = [NSFileManager defaultManager];
	
	NSString* path = MakeApplicationSupportFolder();
	path = [path stringByAppendingPathComponent:@"gaiji"];
	if(![fm fileExistsAtPath:path]){
		NSArray* libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString* libraryPath = ([libraryPaths count] > 0) ? [libraryPaths objectAtIndex:0] : @"";
		NSString* srcPath = [libraryPath stringByAppendingPathComponent:@"Kotonoko"];
		NSError* error;
		if([fm fileExistsAtPath:srcPath]){
			if(![fm copyItemAtPath:srcPath toPath:path error:&error]){
				NSLog(@"Could not copy %@ to %@", srcPath, path);
			}
		}else{
			[fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
		}
	}
	
	return path;
}


//-- IsAppSandboxed
// sandbox を使っているかどうか
BOOL IsAppSandboxed()
{
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    return  ([environment objectForKey:@"APP_SANDBOX_CONTAINER_ID"] != nil);
}
