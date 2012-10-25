//	EBookContainer.m
//	kotonoko
//
//	Copyright 2001-2012 Atsushi Tagami. All rights reserved.
//


#import "EBookContainer.h"
#import "EBook.h"
#import "LineTextAttachmentCell.h"

@implementation EBookContainer
@synthesize ebook = _ebook;
@synthesize paramator = _paramator;

//-- initWithAttribute
// 初期化
-(id) initWithEBook:(EBook*)book
{
	self = [super init];
    if(self){
        _ebook			 = book;
        _string			 = [[NSMutableAttributedString alloc] init];
        _attribute		 = [[NSMutableDictionary alloc] initWithCapacity:1];
        _referenceStack  = NSUIntegerMax;
        _referenceURL	 = nil;
        _paramator		 = nil;
	}
    return self;
}


//-- dealloc
// 後かたづけ
- (void)dealloc
{
    self.paramator = nil;
    
    [_string release];
	[_attribute release];
	[_referenceURL release];
	[super dealloc];
}


//-- ebookNumber
// ebookのid
-(NSUInteger) ebookNumber
{
	return [_ebook ebookNumber];
}

#pragma mark String
//-- appendString
// 文字列の追加
-(void) appendString:(NSString*) string
{
	if(string){
		NSAttributedString* appendString = 
		[[[NSAttributedString alloc] initWithString:string attributes:_attribute] autorelease];
		[_string appendAttributedString:appendString];
	}
}


//-- appendAttributedString
// 文字列の追加
-(void) appendAttributedString:(NSAttributedString*) string
{
	if(string){
		[_string appendAttributedString:string];
	}
}


//-- insertString
// 文字列の挿入
-(void) insertString:(NSString*)string atIndex:(unsigned)index
{
	if(string){
		NSAttributedString* appendString = 
			[[[NSAttributedString alloc] initWithString:string attributes:_attribute] autorelease];
		[_string insertAttributedString:appendString atIndex:index];
	}
}


//-- string
// 普通の文字列を返す
-(NSString*) string
{
	return [_string string];
}


//-- attributedSting
// 修飾文字列を返す
-(NSAttributedString*) attributedString
{
	return _string;
}

#pragma mark Attribute

//-- setAttribute
// 装飾の設定
-(void) setAttribute:(NSDictionary*) attribute
{
	[_attribute setDictionary:attribute];
}


//-- addAttribute
// 装飾を追加する
-(void) addAttribute:(NSDictionary*) attribute
{
	NSEnumerator* e = [attribute keyEnumerator];
	NSString* key;
	while(key = [e nextObject]){
		[_attribute setObject:[attribute objectForKey:key] forKey:key];
	}
}


//-- removeAttribute
// 装飾を削除する
-(void) removeAttribute:(NSString*) key
{
	[_attribute removeObjectForKey:key];
}



//-- setCenterTextAlignment
// 中央揃えにする
-(void) setCenterTextAlignment:(BOOL) center
{
	if(center){
		NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[style setAlignment:NSCenterTextAlignment];
		[_attribute setObject:style forKey:NSParagraphStyleAttributeName];
        [style release];
	}else{
		[_attribute removeObjectForKey:NSParagraphStyleAttributeName];
	}
}



//-- currentTextColor
// 現在のtext colorを返す
-(NSColor*) currentTextColor
{
	NSColor* color = nil;
	if(_referenceStack < NSUIntegerMax){
		color = [self paramatorForkey:EBReferenceTextColor];
	}
	if(!color){
		color = [_attribute objectForKey:NSForegroundColorAttributeName];
	}
	if(!color){
		color = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	}
	return color;
}


#pragma mark Paramator
//-- paramatorForkey
// パラメタ変数を返す
-(id) paramatorForkey:(NSString*) key
{
    return (key != nil && _paramator != nil) ? [_paramator objectForKey:key] : nil;
}


//-- hasParamator
// パラメタがあるかどうかの設定
-(BOOL) hasParamator
{
	return (_paramator != nil);
}


#pragma mark References

//-- referenceMaker
// 現在の文字列の長さを返す
-(NSUInteger) referenceMaker
{
	return [_string length];
}


//-- stackReference
// 現在のカーソルの位置を記憶しておく
-(void) stackReference
{
	_referenceStack = [self referenceMaker];
}


//-- setReferenceURL
// reference先を設定する
-(void) setReferenceURL:(NSString*)string
{
	if(string != _referenceURL){
		[_referenceURL release];
		_referenceURL = [string retain];
	}
}


//-- insertRefernce
//  referenceを展開する
-(void) insertReference
{
	if(_referenceStack != NSUIntegerMax){
		[self insertReferenceWithURL:_referenceURL range:NSMakeRange(_referenceStack, [self referenceMaker] - _referenceStack)];
		_referenceStack = NSUIntegerMax;
	}
}



//-- insertReferenceWithURL:range:
// referenceを展開する
-(void) insertReferenceWithURL:(NSString*) string
						range:(NSRange) referenceRange
{
	if (!string) return;
	NSURL* url = [NSURL URLWithString:string];
	
	NSRange limitRange = referenceRange;
	NSUInteger endpoint = referenceRange.location + referenceRange.length;
	int i;
	
	NSRange range = NSMakeRange(0,0);
	// 入れ子のreferenceを避けてreferenceを入れる
	for(i = referenceRange.location; i < endpoint; i += range.length){
		if([_string attribute:NSLinkAttributeName atIndex:i longestEffectiveRange:&range inRange:limitRange] == nil){
			if(range.length > 0){
				[_string addAttribute:NSLinkAttributeName value:url range:range];
			}else{
				range.length = referenceRange.length;
			}
		}
		if(range.length <= 0){ range.length = referenceRange.length; } //無限ループ回避
	}
}


#pragma mark Image
//-- appendImage
// 画像を挿入する
-(void) appendImage:(NSImage*) image
{
	NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
	
	NSTextAttachmentCell* cell = [[[NSTextAttachmentCell alloc] initImageCell:image] autorelease];
	[attachment setAttachmentCell:cell];
	NSUInteger start = [_string length];
	[_string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
	id style;
	if((style = [_attribute objectForKey:NSParagraphStyleAttributeName]) != NULL){
		NSRange range = NSMakeRange(start, [_string length] - start);
		[_string addAttribute:NSParagraphStyleAttributeName value:style range:range];
	}
}

@end


