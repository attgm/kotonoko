//	EBookPluginHookFunctions.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//

#include "EBookPluginHookFunctions.h"


#define HOOK_PROTOTYPE(c) EB_Error_Code c(EB_Book*			inBook, \
										  EB_Appendix*		inAppendix, \
										  void*	inContainer, \
										  EB_Hook_Code		inCode, \
										  int				argc, \
										  const unsigned int*	argv)

HOOK_PROTOTYPE(hook_tags);
HOOK_PROTOTYPE(hook_emphasis);
HOOK_PROTOTYPE(hook_superscript);
HOOK_PROTOTYPE(hook_subscript);
HOOK_PROTOTYPE(hook_keyword);
HOOK_PROTOTYPE(hook_reference);
HOOK_PROTOTYPE(hook_narrow_font);
HOOK_PROTOTYPE(hook_wide_font);
HOOK_PROTOTYPE(hook_wave);
HOOK_PROTOTYPE(hook_euc_to_unicode);
HOOK_PROTOTYPE(hook_gb_to_unicode);
HOOK_PROTOTYPE(hook_color_image);
HOOK_PROTOTYPE(hook_mono_image);
HOOK_PROTOTYPE(hook_mpeg);
HOOK_PROTOTYPE(hook_nop);


const EB_Hook kTextHook[] = {
{EB_HOOK_NARROW_JISX0208,		hook_euc_to_unicode},
{EB_HOOK_WIDE_JISX0208,			hook_euc_to_unicode},
{EB_HOOK_GB2312,				hook_gb_to_unicode},
{EB_HOOK_NARROW_FONT,			hook_narrow_font},
{EB_HOOK_WIDE_FONT,				hook_wide_font},
{EB_HOOK_NEWLINE,				hook_tags},
{EB_HOOK_BEGIN_MONO_GRAPHIC,	hook_mono_image},
{EB_HOOK_END_MONO_GRAPHIC,		hook_mono_image},
{EB_HOOK_BEGIN_GRAY_GRAPHIC,	nil},
{EB_HOOK_END_GRAY_GRAPHIC,		nil},
{EB_HOOK_BEGIN_COLOR_BMP,		hook_color_image},
{EB_HOOK_BEGIN_COLOR_JPEG,		hook_color_image},
{EB_HOOK_END_COLOR_GRAPHIC,		nil},
{EB_HOOK_END_IN_COLOR_GRAPHIC,	nil},
{EB_HOOK_BEGIN_WAVE,			hook_wave},
{EB_HOOK_END_WAVE,				hook_wave},
{EB_HOOK_BEGIN_MPEG,			hook_mpeg},
{EB_HOOK_END_MPEG,				nil},
{EB_HOOK_SET_INDENT,			hook_tags},
{EB_HOOK_BEGIN_EMPHASIS,		hook_emphasis},
{EB_HOOK_END_EMPHASIS,			hook_emphasis},
{EB_HOOK_BEGIN_SUPERSCRIPT,		hook_superscript},
{EB_HOOK_END_SUPERSCRIPT,		hook_superscript},
{EB_HOOK_BEGIN_SUBSCRIPT,		hook_subscript},
{EB_HOOK_END_SUBSCRIPT,			hook_subscript},
{EB_HOOK_BEGIN_KEYWORD,			hook_keyword},
{EB_HOOK_END_KEYWORD,			hook_keyword},
{EB_HOOK_BEGIN_REFERENCE,		hook_reference},
{EB_HOOK_END_REFERENCE,			hook_reference},
{EB_HOOK_NULL,					nil}
};


EB_Hook* get_text_hook(void){ return (EB_Hook*)kTextHook; };


EB_Error_Code hook_tags(EB_Book*		inBook,
						EB_Appendix*		inAppendix,
						void*			inContainer,
						EB_Hook_Code		inCode,
						int			argc,
						const unsigned int*	argv)
{
    EBookContainer* container = (EBookContainer*)inContainer; 
    
    switch(inCode){
		case EB_HOOK_NEWLINE:
			[container appendString:@"\r"];
			break;
			
		case EB_HOOK_SET_INDENT:
			[container appendString:@" "];
			break;
    }
    return EB_SUCCESS;
}



//-- hook_emphasis
// emphasisの処理
EB_Error_Code hook_emphasis(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	switch(inCode){
		case EB_HOOK_BEGIN_EMPHASIS:
			[container appendString:@"<span class=\"emphasis\">"];
			break;
		case EB_HOOK_END_EMPHASIS:
			[container appendString:@"</span>"];
			break;
	}
	return EB_SUCCESS;
}


//-- hook_superscript
// superscriptの処理
EB_Error_Code hook_superscript(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							   int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	switch(inCode){
		case EB_HOOK_BEGIN_SUPERSCRIPT:
			[container appendString:@"<sup>"];
			break;
		case EB_HOOK_END_SUPERSCRIPT:
			[container appendString:@"</sup>"];
			break;
	}
	return EB_SUCCESS;
}



//-- hook_subscript
// subscriptの処理
EB_Error_Code hook_subscript(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							 int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	switch(inCode){
		case EB_HOOK_BEGIN_SUBSCRIPT:
			[container appendString:@"<sub>"];
			break;
		case EB_HOOK_END_SUBSCRIPT:
			[container appendString:@"</sub>"];
			break;
	}
	return EB_SUCCESS;
}


//-- hook_keyword
// keywordの処理
EB_Error_Code hook_keyword(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
						   int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	switch(inCode){
		case EB_HOOK_BEGIN_KEYWORD:
			[container appendString:@"<span class=\"keyword\">"];
			break;
		case EB_HOOK_END_KEYWORD:
			[container appendString:@"</span>"];
			break;
	}
	return EB_SUCCESS;
}



//-- hook_reference
// referenceの処理
EB_Error_Code hook_reference(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							 int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	switch(inCode){
		case EB_HOOK_BEGIN_REFERENCE:
			[container appendString:@"<a href=\"javascript:openReference('"];
			[container setMaker:marker_reference];
			[container appendString:@")\">"];
			break;
			
		case EB_HOOK_END_REFERENCE:
			[container appendString:@"</a>"];
			[container insertString:[NSString stringFromFormat:@"%d, %d", argv[1], argv[2]]
							atIndex:[container markerForKey:marker_reference]];
			break;
	}
	return EB_SUCCESS;
}


//-- hook_mpeg
// mpegの処理
EB_Error_Code hook_mpeg(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
						int argc, const unsigned int* argv)
{
	return EB_SUCCESS;
}


//-- hook_wave
// 音声の処理
EB_Error_Code hook_wave(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
						int argc, const unsigned int* argv)
{
	return EB_SUCCESS;
}


//-- hook_narrow_font
// narrow fontの処理
EB_Error_Code hook_narrow_font(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							   int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	[container appendString:@"?"];	
//	[container appendString:[[container ebook] stringWithCode:argv[0] kind:kEbNarrowFont]];
	return EB_SUCCESS;
}


//-- hook_wide_font
// wide fontの処理
EB_Error_Code hook_wide_font(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							 int argc, const unsigned int* argv)
{
	EBookContainer* container = (EBookContainer*)inContainer;
	
	[container appendString:@"?"];
	//[container appendString:[[container ebook] stringWithCode:argv[0] kind:kEbWideFont]];
	return EB_SUCCESS;
}


//-- hook_color_image
// jpeg/bmpの処理
EB_Error_Code hook_color_image(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							   int argc, const unsigned int* argv)
{
	//EBookContainer* container = (EBookContainer*)inContainer;
	return EB_SUCCESS;
}



//-- hook_mono_image
// 白黒画像の処理
EB_Error_Code hook_mono_image(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
							  int argc, const unsigned int* argv)
{
	//EBookContainer* container = (EBookContainer*)inContainer;
	return EB_SUCCESS;
}


//-- hook_nop
// 何もしないhook
EB_Error_Code hook_nop(EB_Book* inBook,EB_Appendix* inAppendix,void* inContainer,EB_Hook_Code inCode,
					   int argc, const unsigned int* argv)
{
	return EB_SUCCESS;
}



#define EUC_TO_ASCII_TABLE_START	0xa0
#define EUC_TO_ASCII_TABLE_END		0xff

static const unsigned char euc_a1_to_ascii_table[] = {
    0x00, 0x20, 0x00, 0x00, 0x2c, 0x2e, 0xb7, 0x3a,     /* 0xa0 */
    0x3b, 0x3f, 0x21, 0x00, 0x00, 0x00, 0x60, 0x00,     /* 0xa8 */
    0x5e, 0x7e, 0x5f, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xb0 */
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2d, 0x2f,     /* 0xb8 */
    0x5c, 0x00, 0x00, 0x7c, 0x00, 0x00, 0x00, 0x27,     /* 0xc0 */
    0x00, 0x22, 0x28, 0x29, 0x00, 0x00, 0x5b, 0x5d,     /* 0xc8 */
    0x7b, 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xd0 */
    0x00, 0x00, 0x00, 0x00, 0x2b, 0x2d, 0x00, 0x00,     /* 0xd8 */
    0x00, 0x3d, 0x00, 0x3c, 0x3e, 0x00, 0x00, 0x00,     /* 0xe0 */
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5c,     /* 0xe8 */
    0x24, 0x00, 0x00, 0x25, 0x23, 0x26, 0x2a, 0x40,     /* 0xf0 */
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xf8 */
};

static const unsigned char euc_a3_to_ascii_table[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xa0 */
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xa8 */
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,     /* 0xb0 */
    0x38, 0x39, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xb8 */
    0x00, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,     /* 0xc0 */
    0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,     /* 0xc8 */
    0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,     /* 0xd0 */
    0x58, 0x59, 0x5a, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xd8 */
    0x00, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,     /* 0xe0 */
    0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,     /* 0xe8 */
    0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,     /* 0xf0 */
    0x78, 0x79, 0x7a, 0x00, 0x00, 0x00, 0x00, 0x00,     /* 0xf8 */
};


EB_Error_Code
hook_euc_to_unicode(EB_Book*		inBook,
					EB_Appendix*	inAppendix,
					void*		inContainer,
					EB_Hook_Code	inCode,
					int			argc,
					const unsigned int*	argv)
{
    unsigned char code[3];
    NSString*	string;
    unsigned char outcode = 0;
    EBookContainer* container = (EBookContainer*)inContainer;
    
    
    code[0] = argv[0] >> 8;
    code[1] = argv[0] & 0xff;
    code[2] = '\0';
    
	/*if(container->raw){
		[container->raw appendBytes:(void*)code length:2];
	}*/
    
	if (inCode = EB_HOOK_NARROW_JISX0208 &&
		EUC_TO_ASCII_TABLE_START <= code[1] &&
        code[1] <= EUC_TO_ASCII_TABLE_END) {
		if (code[0] == 0xa1) {
			outcode = euc_a1_to_ascii_table[code[1] - EUC_TO_ASCII_TABLE_START];
		} else if (code[0] == 0xa3) {
			outcode = euc_a3_to_ascii_table[code[1] - EUC_TO_ASCII_TABLE_START];
		}
    }
    
    if(outcode == 0){
		string = [[NSString alloc] initWithData:[NSData dataWithBytes:code length:2]
									   encoding:NSJapaneseEUCStringEncoding];
	}else{
		code[0] = outcode;
		code[1] = '\0';
		string = [[NSString alloc] initWithData:[NSData dataWithBytes:code length:1]
									   encoding:NSISOLatin1StringEncoding];
    }
    
    [container appendString:string];
    [string release];
    return EB_SUCCESS;
}


EB_Error_Code
hook_euc_to_unicode(EB_Book*		inBook,
					EB_Appendix*	inAppendix,
					void*		inContainer,
					EB_Hook_Code	inCode,
					int			argc,
					const unsigned int*	argv)
{
    unsigned char code[3];
    NSString*	string;
    EBookContainer* container = (EBookContainer*)inContainer;
    
    
    code[0] = argv[0] >> 8;
    code[1] = argv[0] & 0xff;
    code[2] = '\0';
    
	string = [[NSString alloc] initWithData:[NSData dataWithBytes:code length:2]
								   encoding:NSJapaneseEUCStringEncoding];
	
    [container appendString:string];
    [string release];
    return EB_SUCCESS;
}
