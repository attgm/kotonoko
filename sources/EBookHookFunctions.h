//	EBookHookFunctions.h
//	kotonoko
//
//	Copyright 2001 - 2014 Atsushi Tagami. All rights reserved.
//


#import <eb/eb.h>
#import <eb/text.h>
#import "ELDefines.h"


extern EB_Hook* get_html_hook(void);
extern EB_Hook* get_attributedtext_hook(void);
extern EB_Hook* get_heading_hook(void);
extern EB_Hook* get_candidates_hook(void);
