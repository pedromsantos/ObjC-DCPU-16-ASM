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

#import "SOCQ+NSArray.h"

#import "RegexTokenMatcher.h"
#import "PeekToken.h"
#import "Lexer.h"

@interface Lexer ()

@property(nonatomic, strong) NSString *lineRemaining;
@property(nonatomic, strong) NSArray *tokenMatchers;
@property(nonatomic, strong) NSScanner *scanner;
@property(nonatomic, strong) id <ConsumeTokenStrategy> consumeTokenStrategy;
@property(nonatomic, strong) id <IgnoreTokenStrategy> ignoreTokenStrategy;

- (void)readNextLine;

@end

@implementation Lexer
{
	int lineNumber;
	int columnNumber;
}

@synthesize scanner;
@synthesize token;
@synthesize lineNumber;
@synthesize columnNumber;
@synthesize match;
@synthesize ignoreTokenStrategy;
@synthesize consumeTokenStrategy;

@synthesize lineRemaining;

// This convenience tokenMatchers init is creating an undesired coupling with RegexTokenMatcher
// will leave it for now, since it's very convenient. If in the future another matcher and/or token matcher
// is implemented, that uses other matching technique, then this code should be removed.
// For now intentionally accepting this bit of technical debt for Lexer usage simplification.

- (id)initWithIgnoreTokenStrategy:(id<IgnoreTokenStrategy>)ignoreStrategy
			 consumeTokenStrategy:(id<ConsumeTokenStrategy>)consumeStrategy
{
	NSArray *matchers = [NSArray arrayWithObjects:
										 [[RegexTokenMatcher alloc] initWithToken:INSTRUCTION pattern:@"\\b(((?i)dat)|((?i)set)|((?i)add)|((?i)sub)|((?i)mul)|((?i)div)|((?i)mod)|((?i)shl)|((?i)shr)|((?i)and)|((?i)bor)|((?i)xor)|((?i)ife)|((?i)ifn)|((?i)ifg)|((?i)ifb)|((?i)jsr))\\b"],
										 [[RegexTokenMatcher alloc] initWithToken:REGISTER pattern:@"\\b(((?i)a)|((?i)b)|((?i)c)|((?i)x)|((?i)y)|((?i)z)|((?i)i)|((?i)j)|((?i)pop)|((?i)push)|((?i)peek)|((?i)pc)|((?i)sp)|((?i)o))\\b"],
										 [[RegexTokenMatcher alloc] initWithToken:WHITESPACE pattern:@"(\\r\\n|\\s+)"],
										 [[RegexTokenMatcher alloc] initWithToken:COMMENT pattern:@";.*$"],
										 [[RegexTokenMatcher alloc] initWithToken:LABEL pattern:@":\\w+"],
										 [[RegexTokenMatcher alloc] initWithToken:HEX pattern:@"(0x[0-9a-fA-F]+)"],
										 [[RegexTokenMatcher alloc] initWithToken:INT pattern:@"[0-9]+"],
										 [[RegexTokenMatcher alloc] initWithToken:PLUS pattern:@"\\+"],
										 [[RegexTokenMatcher alloc] initWithToken:COMMA pattern:@","],
										 [[RegexTokenMatcher alloc] initWithToken:OPENBRACKET pattern:@"[\\[\\(]"],
										 [[RegexTokenMatcher alloc] initWithToken:CLOSEBRACKET pattern:@"[\\]\\)]"],
										 [[RegexTokenMatcher alloc] initWithToken:STRING pattern:@"@?\"(\"\"|[^\"])*\""],
										 [[RegexTokenMatcher alloc] initWithToken:LABELREF pattern:@"[a-zA-Z0-9_]+"],
										 nil];


	self.tokenMatchers = matchers;
	self.ignoreTokenStrategy = ignoreStrategy;
	self.consumeTokenStrategy = consumeStrategy;
	lineNumber = 0;
	columnNumber = 0;

	return self;
}

- (enum LexerTokenType)token
{
	return self.match.token;
}

- (NSString *)tokenContents
{
	return self.match.content;
}

- (void)lexSource:(NSString*)source
{
	self.scanner = [NSScanner scannerWithString:source];
	[self readNextLine];
}

- (void)readNextLine
{
		NSString *readLine = nil;

		do
		{
			[self.scanner
					scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
					intoString:&readLine];

			[self setLineAndColumnNumberForNewLine:readLine];

			self.lineRemaining = readLine;

		} while(self.lineRemaining != nil && [self.lineRemaining length] == 0);
}

- (void)setLineAndColumnNumberForNewLine:(NSString *)newLine
{
	if(newLine != nil)
	{
		lineNumber++;
		columnNumber = 0;
	}
}

- (BOOL)nextTokenUsingStrategy:(id <ConsumeTokenStrategy>)strategy
{
	id <ConsumeTokenStrategy> oldStragegy = self.consumeTokenStrategy;

	self.consumeTokenStrategy = strategy;

	BOOL result = [self nextToken];

	self.consumeTokenStrategy = oldStragegy;

	return result;
}

- (BOOL)nextToken
{
	if(lineRemaining == nil)
	{
		return NO;
	}

	[self matchToken];

	if([self.ignoreTokenStrategy isTokenToBeIgnored:self.token])
	{
		[self nextToken];
	}

	return YES;
}

- (void)matchToken
{
	NSArray *matchers = [self.tokenMatchers where:^(id obj)
	{
		id <TokenMatcher> matcher = (id <TokenMatcher>) obj;
		[matcher matchToken:self.lineRemaining];
		return (BOOL) ([matcher.content length] > 0);
	}];

	id <TokenMatcher> tokenMatcher = [matchers firstObject];

	if(tokenMatcher == nil)
	{
		@throw [NSString stringWithFormat:@"Unable to match against any tokens at line %d position %d \"%@\"",
										  lineNumber,
										  columnNumber,
										  lineRemaining];
	}

	self.match = tokenMatcher;
	[self consumeToken:tokenMatcher.token characters:tokenMatcher.content];
}

- (void)consumeToken:(enum LexerTokenType)tkn characters:(NSString *)matched
{
	if([self.consumeTokenStrategy isTokenToBeConsumed:tkn] || [self.ignoreTokenStrategy isTokenToBeIgnored:tkn])
	{
		columnNumber += [matched length];
		self.lineRemaining = [self.lineRemaining substringFromIndex:[matched length]];

		if([self.lineRemaining length] == 0)
		{
			[self readNextLine];
		}
	}
}

@end
