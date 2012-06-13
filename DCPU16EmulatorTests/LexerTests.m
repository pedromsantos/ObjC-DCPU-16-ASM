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

#import "LexerTests.h"
#import "RegexTokenMatcher.h"
#import "LexerTokenType.h"
#import "Lexer.h"
#import "PeekToken.h"
#import "ConsumeToken.h"
#import "IgnoreWhiteSpaceTokenStrategy.h"

@implementation LexerTests

@synthesize tokenDefinitions;

- (void)setUp
{
    self.tokenDefinitions = [NSArray arrayWithObjects:
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
    
    [super setUp];
}

- (void)testNextCosumesAndReturnsNextToken
{
    NSString *code = @"SET A, 0x30";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    [lexer consumeNextToken];
    int token1 = lexer.token;
    [lexer consumeNextToken];
    int token2 = lexer.token;
    
    STAssertTrue(token1 != token2, nil);
}

- (void)testPeekReadsWithoutConsumingToken
{
    NSString *code = @"SET A, 0x30";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[PeekToken alloc] init];
    
    id<ConsumeTokenStrategy> consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    [lexer consumeNextToken];
    int token1 = lexer.token;
    [lexer consumeNextToken];
    int token2 = lexer.token;
    [lexer consumeNextTokenUsingStrategy:consumeTokenStrategy];
    int token3 = lexer.token;
    
    STAssertTrue(token1 == token2 && token1 == token3, nil);
}

- (void)testNextCalledWithEmptySourceNotGenerateTokens
{
    NSString *code = @"";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    [lexer consumeNextToken];
    
    STAssertNil(lexer.tokenContents, nil);
}

- (void)testNextCalledWithCommentOnlyGenertesCorrectTokens
{
    NSString *code = @"; Try some basic stuff";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    [lexer consumeNextToken];
    
    STAssertTrue(lexer.token == COMMENT, nil);
}

- (void)testNextCalledWithIgnoreWhitespaceGenertesCorrectTokens
{
    NSString *code = @"SET A, 0x30";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    lexer.ignoreTokenStrategy = [[IgnoreWhiteSpaceTokenStrategy alloc] init];
    
    int expectedTokens[4] = { INSTRUCTION, REGISTER, COMMA, HEX };
    
    for (int i = 0; i < 4; i++) 
    {
        [lexer consumeNextToken];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetRegisterWithHexLiteralGenertesCorrectTokens
{
    NSString *code = @"SET A, 0x30";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    int expectedTokens[6] = { INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX };
    
    for (int i = 0; i < 6; i++) 
    {
        [lexer consumeNextToken];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetMemoryAddressWithLiteralGenertesCorrectInstructionSet
{
    NSString *code = @"SET [0x1000], 0x20";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    int expectedTokens[8] = { INSTRUCTION, WHITESPACE, OPENBRACKET, HEX, CLOSEBRACKET, COMMA, WHITESPACE, HEX };
    
    for (int i = 0; i < 8; i++) 
    {
        [lexer consumeNextToken];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetRegisterWithDecimalLiteralGenertesCorrectInstructionSet
{
    NSString *code = @"SET I, 10";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    int expectedTokens[6] = { INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT };
    
    for (int i = 0; i < 6; i++) 
    {
        [lexer consumeNextToken];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithSetRegisterWithLabelRefGenertesCorrectInstructionSet
{
    NSString *code = @"SET PC, crash";
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    int expectedTokens[6] = { INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF };
        
    for (int i = 0; i < 6; i++) 
    {
        [lexer consumeNextToken];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

- (void)testNextCalledWithNotchSampleGenertesCorrectInstructionSet
{
    NSString *code = @"\n\
; Try some basic stuff\n\
            SET A, 0x30              ; 7c01 0030\n\
            SET [0x1000], 0x20       ; 7de1 1000 0020\n\
            SUB A, [0x1000]          ; 7803 1000\n\
            IFN A, 0x10              ; c00d\n\
            SET PC, crash            ; 7dc1 001a [*]\n\
\n\
; Do a loopy thing\n\
            SET I, 10                ; a861\n\
            SET A, 0x2000            ; 7c01 2000\n\
:loop       SET [0x2000+I], [A]      ; 2161 2000\n\
            SUB I, 1                 ; 8463\n\
            IFN I, 0                 ; 806d\n\
            SET PC, loop             ; 7dc1 000d [*]\n\
\n\
; Call a subroutine\n\
            SET X, 0x4               ; 9031\n\
            JSR testsub              ; 7c10 0018 [*]\n\
            SET PC, crash            ; 7dc1 001a [*]\n\
\n\
:testsub    SHL X, 4                 ; 9037\n\
            SET PC, POP              ; 61c1\n\
\n\
; Hang forever. X should now be 0x40 if everything went right.\n\
:crash      SET PC, crash            ; 7dc1 001a [*]";
    
    NSScanner *codeScanner = [NSScanner scannerWithString:code];
    
    Lexer *lexer = [[Lexer alloc] initWithTokenMatchers:self.tokenDefinitions scanner:codeScanner];
    lexer.consumeTokenStrategy = [[ConsumeToken alloc] init];
    
    int expectedTokens[155] = {
        COMMENT, 
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, OPENBRACKET, HEX, CLOSEBRACKET, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, OPENBRACKET, HEX, CLOSEBRACKET, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        
        COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        LABEL, WHITESPACE, INSTRUCTION, WHITESPACE, OPENBRACKET, HEX, PLUS, REGISTER, CLOSEBRACKET, COMMA, WHITESPACE, OPENBRACKET, REGISTER, CLOSEBRACKET, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        
        COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, HEX, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        LABEL, WHITESPACE, INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, INT, WHITESPACE, COMMENT,
        INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, REGISTER, WHITESPACE, COMMENT,
        
        COMMENT,
        LABEL, WHITESPACE, INSTRUCTION, WHITESPACE, REGISTER, COMMA, WHITESPACE, LABELREF, WHITESPACE, COMMENT,
        COMMENT,
        COMMENT
    };
    
    for (int i = 0; i < 155; i++) 
    {
        [lexer consumeNextToken];
        STAssertTrue(lexer.token == expectedTokens[i], nil);
    }
}

@end
