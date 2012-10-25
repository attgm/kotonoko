//	EBookHookFunctions.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import <eb/error.h>
#import <eb/binary.h>
#import "ELDefines.h"
#import "EBook.h"
#import "EBookContainer.h"
#import "CandidateContainer.h"
//#import "EBookReference.h"
#import "EBookHookFunctions.h"


#define HOOK_PROTOTYPE(c) EB_Error_Code c(EB_Book*			inBook, \
										  EB_Appendix*		inAppendix, \
										  void*	inContainer, \
										  EB_Hook_Code		inCode, \
										  int				argc, \
										  const unsigned int*	argv)

HOOK_PROTOTYPE(hook_euc_to_unicode);
HOOK_PROTOTYPE(hook_gb_to_unicode);
HOOK_PROTOTYPE(hook_narrow_font_tags);
HOOK_PROTOTYPE(hook_wide_font_tags);
HOOK_PROTOTYPE(hook_style_tags);
HOOK_PROTOTYPE(hook_img_tags);
HOOK_PROTOTYPE(hook_mono_img_tags);
HOOK_PROTOTYPE(hook_wav_tags);
HOOK_PROTOTYPE(hook_mpeg_tags);
HOOK_PROTOTYPE(hook_anchor);
HOOK_PROTOTYPE(hook_scripts);
HOOK_PROTOTYPE(hook_candidate_tags);
HOOK_PROTOTYPE(hook_test);
HOOK_PROTOTYPE(hook_html_tags);

const EB_Hook kAttributedTextHook[] = {
	{EB_HOOK_NARROW_JISX0208,		hook_euc_to_unicode},
	{EB_HOOK_WIDE_JISX0208,			hook_euc_to_unicode},
	{EB_HOOK_GB2312,				hook_gb_to_unicode},
	{EB_HOOK_NARROW_FONT,			hook_narrow_font_tags},
	{EB_HOOK_WIDE_FONT,				hook_wide_font_tags},
	{EB_HOOK_NEWLINE,				hook_style_tags},
	{EB_HOOK_BEGIN_MONO_GRAPHIC,	hook_mono_img_tags},
	{EB_HOOK_END_MONO_GRAPHIC,		hook_mono_img_tags},
	{EB_HOOK_BEGIN_GRAY_GRAPHIC,	hook_img_tags},
	{EB_HOOK_END_GRAY_GRAPHIC,		hook_img_tags},
	{EB_HOOK_BEGIN_COLOR_BMP,		hook_img_tags},
	{EB_HOOK_BEGIN_COLOR_JPEG,		hook_img_tags},
	{EB_HOOK_BEGIN_IN_COLOR_BMP,	hook_img_tags},
	{EB_HOOK_BEGIN_IN_COLOR_JPEG,	hook_img_tags},
	{EB_HOOK_END_COLOR_GRAPHIC,		hook_img_tags},
	{EB_HOOK_END_IN_COLOR_GRAPHIC,	hook_img_tags},
	{EB_HOOK_BEGIN_WAVE,			hook_wav_tags},
	{EB_HOOK_END_WAVE,				hook_wav_tags},
	{EB_HOOK_BEGIN_MPEG,			hook_mpeg_tags},
	{EB_HOOK_END_MPEG,				hook_mpeg_tags},
	{EB_HOOK_SET_INDENT,			hook_style_tags},
	{EB_HOOK_BEGIN_EMPHASIS,		hook_style_tags},
	{EB_HOOK_END_EMPHASIS,			hook_style_tags},
	{EB_HOOK_BEGIN_SUPERSCRIPT,		hook_style_tags},
	{EB_HOOK_END_SUPERSCRIPT,		hook_style_tags},
	{EB_HOOK_BEGIN_SUBSCRIPT,		hook_style_tags},
	{EB_HOOK_END_SUBSCRIPT,			hook_style_tags},
	{EB_HOOK_BEGIN_KEYWORD,			hook_style_tags},
	{EB_HOOK_END_KEYWORD,			hook_style_tags},
	{EB_HOOK_BEGIN_REFERENCE,		hook_anchor},
	{EB_HOOK_END_REFERENCE,			hook_anchor},
	{EB_HOOK_BEGIN_CANDIDATE,		hook_anchor},
	{EB_HOOK_END_CANDIDATE_GROUP,	hook_anchor},
	{EB_HOOK_NULL,					nil}
};



const EB_Hook kHtmlHook[] = {
	{EB_HOOK_NARROW_JISX0208,		hook_euc_to_unicode},
	{EB_HOOK_WIDE_JISX0208,			hook_euc_to_unicode},
	{EB_HOOK_GB2312,				hook_gb_to_unicode},
	{EB_HOOK_NARROW_FONT,			hook_narrow_font_tags},
	{EB_HOOK_WIDE_FONT,				hook_wide_font_tags},
	{EB_HOOK_NEWLINE,				hook_html_tags},
	{EB_HOOK_SET_INDENT,			hook_html_tags},
	{EB_HOOK_BEGIN_EMPHASIS,		hook_html_tags},
	{EB_HOOK_END_EMPHASIS,			hook_html_tags},
	{EB_HOOK_BEGIN_SUPERSCRIPT,		hook_html_tags},
	{EB_HOOK_END_SUPERSCRIPT,		hook_html_tags},
	{EB_HOOK_BEGIN_SUBSCRIPT,		hook_html_tags},
	{EB_HOOK_END_SUBSCRIPT,			hook_html_tags},
	{EB_HOOK_BEGIN_KEYWORD,			hook_html_tags},
	{EB_HOOK_END_KEYWORD,			hook_html_tags},
/*	{EB_HOOK_BEGIN_REFERENCE,		hook_anchor},
	{EB_HOOK_END_REFERENCE,			hook_anchor},
	{EB_HOOK_BEGIN_CANDIDATE,		hook_anchor},
	{EB_HOOK_END_CANDIDATE_GROUP,	hook_anchor},*/
	{EB_HOOK_NULL,					nil}
};


const EB_Hook kHeadingTextHooks[] = {
    {EB_HOOK_NARROW_JISX0208,		hook_euc_to_unicode},
    {EB_HOOK_WIDE_JISX0208,			hook_euc_to_unicode},
	{EB_HOOK_GB2312,				hook_gb_to_unicode},
    {EB_HOOK_NARROW_FONT,			hook_narrow_font_tags},
    {EB_HOOK_WIDE_FONT,				hook_wide_font_tags},
    {EB_HOOK_NEWLINE,				nil},
	{EB_HOOK_BEGIN_SUPERSCRIPT,		hook_scripts},
	{EB_HOOK_END_SUPERSCRIPT,		hook_scripts},
	{EB_HOOK_BEGIN_SUBSCRIPT,		hook_scripts},
	{EB_HOOK_END_SUBSCRIPT,			hook_scripts},
    {EB_HOOK_NULL, NULL},
};


const EB_Hook kCandidatesHooks[] = {
    {EB_HOOK_NARROW_JISX0208,		hook_euc_to_unicode},
    {EB_HOOK_WIDE_JISX0208,			hook_euc_to_unicode},
	{EB_HOOK_GB2312,				hook_gb_to_unicode},
    {EB_HOOK_NARROW_FONT,			hook_narrow_font_tags},
    {EB_HOOK_WIDE_FONT,				hook_wide_font_tags},
    {EB_HOOK_BEGIN_CANDIDATE,		hook_candidate_tags},
    {EB_HOOK_END_CANDIDATE_GROUP,   hook_candidate_tags},
    {EB_HOOK_END_CANDIDATE_LEAF,	hook_candidate_tags},
    {EB_HOOK_NULL,					NULL},
};


EB_Hook* get_html_hook(void){ return (EB_Hook*)kHtmlHook; };
EB_Hook* get_attributedtext_hook(void){ return (EB_Hook*)kAttributedTextHook; };
EB_Hook* get_heading_hook(void){ return (EB_Hook*)kHeadingTextHooks; };
EB_Hook* get_candidates_hook(void){ return (EB_Hook*)kCandidatesHooks; };


#pragma mark AttributedString tags
//-- hook_img_tags
// 画像タグの処理
EB_Error_Code hook_img_tags(EB_Book*			book,
							EB_Appendix*		appendix,
							void*				userinfo,
							EB_Hook_Code		code,
							int					argc,
							const unsigned int*	argv)
{
	EBookContainer* container = (EBookContainer*)userinfo;
	EBook* ebook = [container ebook];
	
	switch(code){
		case EB_HOOK_BEGIN_COLOR_BMP:
		case EB_HOOK_BEGIN_COLOR_JPEG:
		case EB_HOOK_BEGIN_IN_COLOR_BMP:
		case EB_HOOK_BEGIN_IN_COLOR_JPEG:
			[container setCenterTextAlignment:YES];
			[container appendString:@"\r"];
			break;
		
		case EB_HOOK_END_COLOR_GRAPHIC:
		case EB_HOOK_END_IN_COLOR_GRAPHIC:
			[container appendString:@"\r"];
			EBLocation location = EBMakeLocation([container ebookNumber], argv[2], argv[3]);
			SSize size = EBMakeSize(0,0);
			NSImage* bitmap = [ebook imageAt:location type:kImageTypeColor size:size];
			if(bitmap){
				[container appendImage:bitmap];
			}
			[container setCenterTextAlignment:NO];
			[container appendString:@"\r"];
			break;
	}	
	
	
	return EB_SUCCESS;
}


//-- hook_mono_img_tags
// 画像タグの処理
EB_Error_Code hook_mono_img_tags(EB_Book*			book,
								 EB_Appendix*		appendix,
								 void*				userinfo,
								 EB_Hook_Code		code,
								 int					argc,
								 const unsigned int*	argv)
{
	EBookContainer* container = (EBookContainer*)userinfo;
	EBook* ebook = [container ebook];
	static SSize imageSize;
	EBLocation location;
	
	switch(code){
		case EB_HOOK_BEGIN_MONO_GRAPHIC:
			imageSize = EBMakeSize(argv[3], argv[2]);
			[container appendString:@"\r"];
			[container setCenterTextAlignment:YES];
			break;
		case EB_HOOK_END_MONO_GRAPHIC:
			location = EBMakeLocation([container ebookNumber], argv[1], argv[2]);
			NSImage* bitmap = [ebook imageAt:location type:kImageTypeMono size:imageSize];
			if(bitmap){
				[container appendString:@"\r"];
				[container appendImage:bitmap];
			}
			[container setCenterTextAlignment:NO];
			break;
	}
	
	return EB_SUCCESS;
}



//-- hook_wav_tags
// 音声の処理
EB_Error_Code hook_wav_tags(EB_Book*			book,
							EB_Appendix*		appendix,
							void*				userinfo,
							EB_Hook_Code		code,
							int					argc,
							const unsigned int*	argv)
{
	EBookContainer* container = (EBookContainer*)userinfo;
	
	switch(code){
		case EB_HOOK_BEGIN_WAVE:
		{
			NSString* path = [NSString stringWithFormat:@"ebwave:/%lu/%d/%d/%d/%d",
							  (unsigned long)[container ebookNumber], argv[2], argv[3], argv[4], argv[5]];
			[container stackReference];
			[container setReferenceURL:path];
		}
			break;
			
		case EB_HOOK_END_WAVE:
			[container insertReference];
			break;
	}
	return EB_SUCCESS;
}


//-- hook_mpeg_tag
// mpegの処理
EB_Error_Code hook_mpeg_tags(EB_Book* inBook,EB_Appendix* inAppendix,void* userinfo,EB_Hook_Code code,
						int argc, const unsigned int* argv)
{
	char filename[EB_MAX_DIRECTORY_NAME_LENGTH + 1];
	EBookContainer* container = (EBookContainer*)userinfo;
	
	switch(code){
		case EB_HOOK_BEGIN_MPEG:
			[container setCenterTextAlignment:YES];
			[container appendString:@"\r"];
			if (eb_compose_movie_file_name(&argv[2], filename) != EB_SUCCESS){
				NSLog(@"compose_movie_file_name");
			}else{
				NSString* path = [NSString stringWithFormat:@"ebmovie:/%lu/%@",
								  (unsigned long)[container ebookNumber],
								  [NSString stringWithCString:filename encoding:NSASCIIStringEncoding]];
				NSUInteger start = [container referenceMaker];
				NSImage* image = [NSImage imageNamed:@"icon_movie.png"];
				[container appendImage:image];
				NSUInteger end = [container referenceMaker];
				[container insertReferenceWithURL:path range:NSMakeRange(start, (end - start))];
				[container appendString:@"\r"];
			}
			break;
			
		case EB_HOOK_END_MPEG:
			[container setCenterTextAlignment:NO];
			[container appendString:@"\r"];
			break;
	}
	return EB_SUCCESS;
}



//-- hook_style_tags
// style関係の各種タグ
EB_Error_Code hook_style_tags(EB_Book*		inBook,
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
			if([[container attributedString] length] > 0){
				[container appendString:@" "];
			}
			break;
		case EB_HOOK_BEGIN_EMPHASIS:
			[container setAttribute:[container paramatorForkey:EBEmphasisAttributes]];
			break;
		case EB_HOOK_BEGIN_SUPERSCRIPT:
			[container setAttribute:[container paramatorForkey:EBSuperScriptAttributes]];
			break;
		case EB_HOOK_BEGIN_SUBSCRIPT:
			[container setAttribute:[container paramatorForkey:EBSubScriptAttributes]];
			break;
		case EB_HOOK_BEGIN_KEYWORD:
			[container setAttribute:[container paramatorForkey:EBKeywordAttributes]];
			break;
		case EB_HOOK_END_SUBSCRIPT:
		case EB_HOOK_END_SUPERSCRIPT:
		case EB_HOOK_END_EMPHASIS:
		case EB_HOOK_END_KEYWORD:
			[container setAttribute:[container paramatorForkey:EBTextAttributes]];
			break;
    }
    return EB_SUCCESS;
}


//-- hook_anchor
// anchorタグの処理
EB_Error_Code hook_anchor(EB_Book*				book,
						  EB_Appendix*			appendix,
						  void*					userinfo,
						  EB_Hook_Code			code,
						  int					argc,
						  const unsigned int*	argv)
{
	EBookContainer* container = (EBookContainer*) userinfo;
	
	switch(code){
		case EB_HOOK_BEGIN_REFERENCE:
		case EB_HOOK_BEGIN_CANDIDATE:
			[container stackReference];
			break;
		case EB_HOOK_END_REFERENCE:
		case EB_HOOK_END_CANDIDATE_GROUP:
			[container setReferenceURL:[NSString stringWithFormat:@"eb:/%lu/%d/%d", (unsigned long)[container ebookNumber], argv[1], argv[2]]];
			[container insertReference];
			break;
	}
	return EB_SUCCESS;
}



//-- hook_narrow_font_tags
// narrow fontの処理
EB_Error_Code hook_narrow_font_tags(EB_Book*				book,
									EB_Appendix*			appendix,
									void*					userinfo,
									EB_Hook_Code			code,
									int						argc,
									const unsigned int*		argv)
{
	EBookContainer* container = (EBookContainer*)userinfo;
	
	EBook* ebook = [container ebook];
	if(![container hasParamator] || [ebook useAlternativeWithCode:argv[0] kind:kFontTypeNarrow]){
		[container appendString:[ebook stringWithCode:argv[0] kind:kFontTypeNarrow]];
	}else{
		NSColor* color = [container currentTextColor];
		NSImage* bitmap = [ebook fontImageWithCode:argv[0]  kind:kFontTypeNarrow size:kFontImageSizeSmall color:color];
		if(bitmap != nil){
			int height = [[container paramatorForkey:EBFontImageHeight] intValue];
			NSSize size = [bitmap size];
			NSInteger width = round(height * size.width / size.height);
			[bitmap setSize:NSMakeSize(width,height)];
			
			[container appendImage:bitmap];
		}else{
			[container appendString:@"?"];
		}
	}
	
	NSNumber* showGaijiCode = [container paramatorForkey:EBShowGaijiCode];
	if(showGaijiCode && [showGaijiCode boolValue] == YES){
		NSString* url = [NSString stringWithFormat:@"ebgaiji:/%lu/%d/%d", (unsigned long)[container ebookNumber], page_NarrowFont, argv[0]];
		NSUInteger start = [container referenceMaker];
		NSString* tag = [NSString stringWithFormat:@"N:%d", argv[0]];
		[container appendAttributedString:
		 [[[NSAttributedString alloc] initWithString:tag attributes:[container paramatorForkey:EBGaijiAttributes]] autorelease]];
		NSUInteger end = [container referenceMaker];
		[container insertReferenceWithURL:url range:NSMakeRange(start, end-start)];
	}

	
	if([container isKindOfClass:[CandidateContainer class]]){
		unsigned char bytes[2];
		bytes[0] = (argv[0] >> 8) & 0xff;
		bytes[1] = argv[0] & 0xff;
		[(CandidateContainer*)container appendBytes:bytes length:2];
	}
															
	return EB_SUCCESS;
}
	
	
//-- hook_wide_font_tags
// wide fontの処理
EB_Error_Code hook_wide_font_tags(EB_Book*				book,
								  EB_Appendix*			appendix,
								  void*					userinfo,
								  EB_Hook_Code			code,
								  int					argc,
								  const unsigned int*	argv)
{
	EBookContainer* container = (EBookContainer*)userinfo;
	
	EBook* ebook = [container ebook];
	if(![container hasParamator] || [ebook useAlternativeWithCode:argv[0] kind:kFontTypeWide]){
		[container appendString:[ebook stringWithCode:argv[0] kind:kFontTypeWide]];
	}else{
		NSColor* color = [container currentTextColor];
		NSImage* bitmap = [ebook fontImageWithCode:argv[0]  kind:kFontTypeWide size:kFontImageSizeSmall color:color];
		if(bitmap != nil){
			int height = [[container paramatorForkey:EBFontImageHeight] intValue];
			NSSize size = [bitmap size];
			NSInteger width = round(height * size.width / size.height);
			[bitmap setSize:NSMakeSize(width,height)];
			
			[container appendImage:bitmap];
		}else{
			[container appendString:@"?"];
		}		
	}

	NSNumber* showGaijiCode = [container paramatorForkey:EBShowGaijiCode];
	if(showGaijiCode && [showGaijiCode boolValue] == YES){
		NSString* url = [NSString stringWithFormat:@"ebgaiji:/%lu/%d/%d", (unsigned long)[container ebookNumber], page_WideFont, argv[0]];
		NSUInteger start = [container referenceMaker];
		NSString* tag = [NSString stringWithFormat:@"W:%d", argv[0]];
		[container appendAttributedString:
		 [[[NSAttributedString alloc] initWithString:tag attributes:[container paramatorForkey:EBGaijiAttributes]] autorelease]];
		NSUInteger end = [container referenceMaker];
		[container insertReferenceWithURL:url range:NSMakeRange(start, end-start)];
	}

	
	if([container isKindOfClass:[CandidateContainer class]]){
		unsigned char bytes[2];
		bytes[0] = (argv[0] >> 8) & 0xff;
		bytes[1] = argv[0] & 0xff;
		[(CandidateContainer*)container appendBytes:bytes length:2];
	}
	
	return EB_SUCCESS;
}




//-- hook_scripts
// 文字サイズ関係の各種タグ
EB_Error_Code hook_scripts(EB_Book*			inBook,
						   EB_Appendix*			inAppendix,
						   void*				inContainer,
						   EB_Hook_Code			inCode,
						   int					argc,
						   const unsigned int*	argv)
{
    EBookContainer* container = (EBookContainer*)inContainer; 
    
    switch(inCode){
		case EB_HOOK_BEGIN_SUPERSCRIPT:
			[container setAttribute:[container paramatorForkey:EBSuperScriptAttributes]];
			break;
		case EB_HOOK_END_SUPERSCRIPT:
			[container setAttribute:[container paramatorForkey:EBTextAttributes]];
			break;
		case EB_HOOK_BEGIN_SUBSCRIPT:
			[container setAttribute:[container paramatorForkey:EBSubScriptAttributes]];
			break;
		case EB_HOOK_END_SUBSCRIPT:
			[container setAttribute:[container paramatorForkey:EBTextAttributes]];
			break;
    }
    return EB_SUCCESS;
}


//-- hook_scripts
// 文字サイズ関係の各種タグ
EB_Error_Code hook_test(EB_Book*			inBook,
						   EB_Appendix*			inAppendix,
						   void*				inContainer,
						   EB_Hook_Code			code,
						   int					argc,
						   const unsigned int*	argv)
{
    EBookContainer* container = (EBookContainer*)inContainer; 
    
    [container appendString:[NSString stringWithFormat:@"<%d>", code]];
    
	return EB_SUCCESS;
}

#pragma mark Candidate tag
//-- hook_candidate_tags
// 複合検索候補検索時のhook
EB_Error_Code hook_candidate_tags(EB_Book*				book,
								  EB_Appendix*			appendix,
								  void*					userinfo,
								  EB_Hook_Code			code,
								  int					argc, 
								  const unsigned int*	argv)
{
    CandidateContainer* container = (CandidateContainer*)userinfo;
	
	switch(code){
		case EB_HOOK_BEGIN_CANDIDATE:
			[container beginCandidate]; // クリア
			break;
	    
		case EB_HOOK_END_CANDIDATE_GROUP:
			[container endGroupCandidate:EBMakeLocation([container ebookNumber], argv[1], argv[2])];
			break;
			
		case EB_HOOK_END_CANDIDATE_LEAF:
			[container endLeafCandidate];
			break;
    }
    return EB_SUCCESS;
}



#pragma mark HTML tags
//-- hook_html_tags
// style関係の各種タグ
EB_Error_Code hook_html_tags(EB_Book*		inBook,
							  EB_Appendix*		inAppendix,
							  void*			inContainer,
							  EB_Hook_Code		inCode,
							  int			argc,
							  const unsigned int*	argv)
{
    EBookContainer* container = (EBookContainer*)inContainer; 
    
    switch(inCode){
		case EB_HOOK_NEWLINE:
			[container appendString:@"<br />"];
			break;
		case EB_HOOK_SET_INDENT:
			[container appendString:@"&nbsp;"];
			break;
		case EB_HOOK_BEGIN_EMPHASIS:
			[container appendString:@"<span class=\"emphasis\">"];
			break;
		case EB_HOOK_END_EMPHASIS:
			[container appendString:@"</span>"];
			break;
		case EB_HOOK_BEGIN_SUPERSCRIPT:
			[container appendString:@"<sup>"];
			break;
		case EB_HOOK_END_SUPERSCRIPT:
			[container appendString:@"</sup>"];
			break;
		case EB_HOOK_BEGIN_SUBSCRIPT:
			[container appendString:@"<sub>"];
			break;
		case EB_HOOK_END_SUBSCRIPT:
			[container appendString:@"</sub>"];
			break;
		case EB_HOOK_BEGIN_KEYWORD:
			[container appendString:@"<span class=\"keyword\">"];
			break;
		case EB_HOOK_END_KEYWORD:
			[container appendString:@"</span>"];
			break;
    }
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
    
	if([container isKindOfClass:[CandidateContainer class]]){
		[(CandidateContainer*)container appendBytes:code length:2];
	}
    
	if (inCode == EB_HOOK_NARROW_JISX0208 && 
		EUC_TO_ASCII_TABLE_START <= code[1]) {
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



//-- hook_gb_to_unicode
// GBをunicodeに変換する
EB_Error_Code
hook_gb_to_unicode (EB_Book*			inBook,
					EB_Appendix*		inAppendix,
					void*				inContainer,
					EB_Hook_Code		inCode,
					int					argc,
					const unsigned int*	argv)
{
    unsigned char code[3];
    NSString*	string;
    EBookContainer* container = (EBookContainer*)inContainer;
    
    code[0] = argv[0] >> 8;
    code[1] = argv[0] & 0xff;
    code[2] = '\0';
    
	if([container isKindOfClass:[CandidateContainer class]]){
		[(CandidateContainer*)container appendBytes:code length:2];
	}
    
	string = [[NSString alloc] initWithData:[NSData dataWithBytes:code length:2]
								   encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_CN)];
    [container appendString:string];
    [string release];
    return EB_SUCCESS;
}