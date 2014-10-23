//	FontTableElement.m
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//

#import "ELDefines.h"
#import "EBookUtilities.h"
#import "FontTableElement.h"



@implementation FontTableElement

//-- initWithURL:string:identify
// 初期化
-(id) initWithURL:(NSString*) url
	  alternative:(NSString*) string
			  use:(BOOL) use
		 identify:(NSInteger) identify
{
    self = [super init];
    if(self){
        _alternative = [string copyWithZone:nil];
        _useAlternative = use;
        _url = [url copyWithZone:nil];
        _identify = identify;
	}
    return self;
}


//-- elementWithURL:string
// コンストラクタ
+(id) elementWithURL:(NSString*) url
		 alternative:(NSString*) string
				 use:(BOOL) use
			identify:(NSInteger) identify
{
    return [[FontTableElement alloc] 
			 initWithURL:url alternative:string use:use identify:identify];
}



//-- dealloc
// ディストラクタ

#pragma mark -


//-- alternativeString
// 文字列を返す
- (NSString*) alternativeString
{
	return _alternative;
}


//-- setAlternativeString
// 代替文字列を返す
-(void) setAlternativeString:(NSString*) string
{
	@synchronized(self) {
		if(![_alternative isEqualToString:string]){
			_alternative = [string copyWithZone:nil];
			if(!_useAlternative){
				[self setUseAlternativeString:YES];
			}
			SetFontAlternativeString(_url, _alternative);
		}
	}
}


//-- useAlternativeString
// 代替文字列を使うかどうかを返す
-(BOOL) useAlternativeString
{
	return _useAlternative;
}


//-- setUseAltrnativeString
// 代替文字列を使うかどうかを返す
-(void) setUseAlternativeString:(BOOL) useAlterative
{
	if(_useAlternative != useAlterative){
		_useAlternative = useAlterative;
		SetFontUseAlternativeString(_url, _useAlternative);
	}
}


//-- identify
// 識別子を返す
-(NSInteger) identify
{
	return _identify;
}


//-- largeImageRepresentation
// 大きめのイメージを返す
-(NSImage*) largeImageRepresentation
{
	return MakeFontDataFromPath(_url, kFontImageSizeLarge);
}

//-- largeImageRepresentation
// 大きめのイメージを返す
-(NSImage*) imageRepresentation
{
	return MakeFontDataFromPath(_url, kFontImageSizeSmall);
}

@end
