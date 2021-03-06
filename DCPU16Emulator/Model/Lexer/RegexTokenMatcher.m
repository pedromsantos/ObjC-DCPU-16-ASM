/*
 * Copyright (C) 2012 Pedro Santos @pedromsantos
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
 * SOFTWARE.
 */

#import "RegexTokenMatcher.h"
#import "RegexMatcher.h"

@implementation RegexTokenMatcher

@synthesize content;
@synthesize matcher;
@synthesize token;

- (id)initWithToken:(enum LexerTokenType)tokenType pattern:(NSString *)pattern
{
	self = [super init];

	if(self == nil)
	{
		return nil;
	}

	RegexMatcher *regexMatcher = [[RegexMatcher alloc] initWithPattern:pattern];
	self.matcher = regexMatcher;

	self.token = tokenType;

	return self;
}

- (void)matchToken:(NSString *)text
{
	int end = [self.matcher match:text];
	NSString *matchedText = [text substringWithRange:NSMakeRange(0, (NSUInteger) end)];

	self.content = matchedText;
}

@end
