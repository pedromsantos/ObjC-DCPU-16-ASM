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
#import "Lexer.h"

@interface Lexer()

@property (nonatomic, strong) NSString *lineRemaining;
@property (nonatomic, strong) NSArray *tokenMatchers;
@property (nonatomic, strong) NSScanner *scanner;

- (void)readNextLine;
- (void)consumeTokenCharacters:(int)matchedStartIndex;

@end

@implementation Lexer

@synthesize tokenMatchers;
@synthesize scanner;
@synthesize token;
@synthesize lineNumber;
@synthesize columnNumber;
@synthesize tokenContents;
@synthesize ignoreWhiteSpace;

@synthesize lineRemaining;

// This convinience tokenMatchers init is creating an undesired coupling with RegexTokenMatcher
// will leave it for now, since it's very convinient. If in the future another matcher and/or token matcher
// is implemented, that use other matching technique, then this code should be removed.
// For now intentionally accepting this bit of technical debt for Lexer usage simplification.
- (id)initWithScanner:(NSScanner *)textScanner
{
    NSArray* matchers = [NSArray arrayWithObjects:
                         [[RegexTokenMatcher alloc] initWithToken:WHITESPACE pattern:@"(\\r\\n|\\s+)"],
                         [[RegexTokenMatcher alloc] initWithToken:COMMENT pattern:@";.*$"],
                         [[RegexTokenMatcher alloc] initWithToken:LABEL pattern:@":\\w+"],
                         [[RegexTokenMatcher alloc] initWithToken:HEX pattern:@"(0x[0-9a-fA-F]+)"],
                         [[RegexTokenMatcher alloc] initWithToken:INT pattern:@"[0-9]+"],
                         [[RegexTokenMatcher alloc] initWithToken:PLUS pattern:@"\\+"],
                         [[RegexTokenMatcher alloc] initWithToken:COMMA pattern:@","],
                         [[RegexTokenMatcher alloc] initWithToken:OPENBRACKET pattern:@"[\\[\\(]"],
                         [[RegexTokenMatcher alloc] initWithToken:CLOSEBRACKET pattern:@"[\\]\\)]"],
                         [[RegexTokenMatcher alloc] initWithToken:INSTRUCTION pattern:@"\\b(((?i)dat)|((?i)set)|((?i)add)|((?i)sub)|((?i)mul)|((?i)div)|((?i)mod)|((?i)shl)|((?i)shr)|((?i)and)|((?i)bor)|((?i)xor)|((?i)ife)|((?i)ifn)|((?i)ifg)|((?i)ifb)|((?i)jsr))\\b"],
                         [[RegexTokenMatcher alloc] initWithToken:REGISTER pattern:@"\\b(((?i)a)|((?i)b)|((?i)c)|((?i)x)|((?i)y)|((?i)z)|((?i)i)|((?i)j)|((?i)pop)|((?i)push)|((?i)peek)|((?i)pc)|((?i)sp)|((?i)o))\\b"],
                         [[RegexTokenMatcher alloc] initWithToken:STRING pattern:@"@?\"(\"\"|[^\"])*\""],
                         [[RegexTokenMatcher alloc] initWithToken:LABELREF pattern:@"[a-zA-Z0-9_]+"],
                         nil];
    
    return [self initWithTokenMatchers:matchers scanner:textScanner];
}

- (id)initWithTokenMatchers:(NSArray*)matchers scanner:(NSScanner*)textScanner
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    self.tokenMatchers = matchers;
    self.scanner = textScanner;
    self.ignoreWhiteSpace = NO;
    lineNumber = 0;
    columnNumber = 0;
    
    [self readNextLine];
    
    return self;
}

- (void)readNextLine
{
    if ([self.lineRemaining length] == 0)
    {
        NSString *readLine = nil;
        
        do {
            [self.scanner
             scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
             intoString:&readLine];
            
            [self setLineAndColumnNumberForNewLine:readLine];
            
            self.lineRemaining = readLine;
            
        } while (self.lineRemaining != nil && [self.lineRemaining length] == 0);
    }
}

- (void)setLineAndColumnNumberForNewLine:(NSString *)newLine
{
    if(!peekMode && newLine != nil)
    {
        ++lineNumber;
        columnNumber = 0;
    }
}

- (BOOL)peekNextToken
{
    peekMode = YES;
    
    BOOL result = [self consumeNextToken];
    
    peekMode = NO;
    
    return result;
}

- (BOOL)consumeNextToken
{
    if (lineRemaining == nil)
    {
        return NO;
    }
    
    for (id<TokenMatcher> tokenMatcher in self.tokenMatchers)
    {
        int matchedStartIndex = [tokenMatcher match:self.lineRemaining];
        
        if (matchedStartIndex > 0)
        {
            if(!peekMode)
            {
                columnNumber += matchedStartIndex;
            }
            
            self.token = tokenMatcher.token;
            
            [self consumeTokenCharacters:matchedStartIndex];
            
            if([self isIgnoreWhiteSpaceModeOnAndTokenDefinitionIsWhiteSpace:tokenMatcher])
            {
                continue;
            }
            
            [self readNextLine];
            
            return true;
        }
    }
    
    return NO;
}

- (void)consumeTokenCharacters:(int)matchedStartIndex
{
    if(!peekMode)
    {
        self.tokenContents = [self.lineRemaining  substringWithRange:NSMakeRange(0, matchedStartIndex)];
        self.lineRemaining = [self.lineRemaining substringFromIndex:matchedStartIndex];
    }
}

- (BOOL)isIgnoreWhiteSpaceModeOnAndTokenDefinitionIsWhiteSpace:(id<TokenMatcher>)tokenMatcher
{
    return ignoreWhiteSpace && tokenMatcher.token == WHITESPACE;
}

@end
