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
@synthesize tokenContents;
@synthesize ignoreWhiteSpace;

@synthesize lineRemaining;

- (id)initWithScanner:(NSScanner *)textScanner
{
    NSArray* tokenMatchers = [NSArray arrayWithObjects:
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
    
    return [self initWithTokenDefinitions:tokenMatchers scanner:textScanner];
}

- (id)initWithTokenDefinitions:(NSArray*)definitions scanner:(NSScanner*)textScanner
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    self.tokenMatchers = definitions;
    self.scanner = textScanner;
    self.ignoreWhiteSpace = NO;
    
    [self readNextLine];
    
    return self;
}

- (void)readNextLine
{
    if ([self.lineRemaining length] == 0)
    {
        NSString *matchedNewlines = nil;
        
        do {
            [self.scanner
             scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
             intoString:&matchedNewlines];
            ++lineNumber;
            columnNumber = 0;
            
            self.lineRemaining = matchedNewlines;
            
        } while (self.lineRemaining != nil && [self.lineRemaining length] == 0);
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
    
    for (RegexTokenMatcher *tokenDefinition in self.tokenMatchers)
    {
        int matchedStartIndex = [tokenDefinition.matcher match:self.lineRemaining];
        
        if (matchedStartIndex > 0)
        {
            columnNumber += matchedStartIndex;
            self.token = tokenDefinition.token;
            
            [self consumeTokenCharacters:matchedStartIndex];
            
            if([self isIgnoreWhiteSpaceModeOnAndTokenDefinitionIsWhiteSpace:tokenDefinition])
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

- (BOOL)isIgnoreWhiteSpaceModeOnAndTokenDefinitionIsWhiteSpace:(RegexTokenMatcher*)tokenDefinition
{
    return ignoreWhiteSpace && tokenDefinition.token == WHITESPACE;
}

@end
