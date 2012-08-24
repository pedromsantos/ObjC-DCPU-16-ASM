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

#import "ParserTests.h"
#import "Parser.h"
#import "Statment.h"
#import "RegisterOperand.h"
#import "NextWordOperand.h"
#import "IndirectNextWordOperand.h"
#import "ProgramCounterOperand.h"
#import "IndirectRegisterOperand.h"
#import "IndirectNextWordOffsetOperand.h"
#import "Lexer.h"
#import "IgnoreWhiteSpaceTokenStrategy.h"
#import "ConsumeToken.h"
#import "OperandFactory.h"

@implementation ParserTests

- (void)testParseCalledWithEmptySourceDoesNotGenerateStatments
{
	NSString *code = @"";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
												 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 0, nil);
}

- (void)testParseCalledWithOnlyCommentsDoesNotGenerateStatments
{
	NSString *code = @"; Try some basic stuff";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 0, nil);
}

- (void)testParseCalledWithSetRegisterWithDecimalLiteralGenertesCorrectStatments
{
	NSString *code = @"SET I, 10";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 1, nil);

	Statment *s = [p.statments lastObject];

	STAssertTrue(s.opcode == OP_SET, nil);
	STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
	STAssertTrue([s.firstOperand isKindOfClass:[RegisterOperand class]], nil);
	STAssertTrue(s.firstOperand.registerValue == REG_I, nil);
	STAssertTrue([s.secondOperand isKindOfClass:[NextWordOperand class]], nil);
	STAssertTrue(s.secondOperand.nextWord == 10, nil);
}

- (void)testParseCalledWithSetRegisterWithLiteralGenertesCorrectStatments
{
	NSString *code = @"SET A, 0x30";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 1, nil);

	Statment *s = [p.statments lastObject];

	STAssertTrue(s.opcode == OP_SET, nil);
	STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
	STAssertTrue([s.firstOperand isKindOfClass:[RegisterOperand class]], nil);
	STAssertTrue(s.firstOperand.registerValue == REG_A, nil);
	STAssertTrue([s.secondOperand isKindOfClass:[NextWordOperand class]], nil);
	STAssertTrue(s.secondOperand.nextWord == 48, nil);
}

- (void)testParseCalledWithSetMemoryAddressWithLiteralGenertesCorrectStatments
{
	NSString *code = @"SET [0x1000], 0x20";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 1, nil);

	Statment *s = [p.statments lastObject];

	STAssertTrue(s.opcode == OP_SET, nil);
	STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
	STAssertTrue([s.firstOperand isKindOfClass:[IndirectNextWordOperand class]], nil);
	STAssertTrue(s.firstOperand.nextWord == 4096, nil);
	STAssertTrue([s.secondOperand isKindOfClass:[NextWordOperand class]], nil);
	STAssertTrue(s.secondOperand.nextWord == 32, nil);
}

- (void)testParseCalledWithSetOffsetMemoryAddressWithIndirecRegisterGenertesCorrectStatments
{
	NSString *code = @"SET [0x2000+I], [A]";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 1, nil);

	Statment *s = [p.statments lastObject];

	STAssertTrue(s.opcode == OP_SET, nil);
	STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
	STAssertTrue([s.firstOperand isKindOfClass:[IndirectNextWordOffsetOperand class]], nil);
	STAssertTrue(s.firstOperand.nextWord == 0x2000, nil);
	STAssertTrue([s.secondOperand isKindOfClass:[IndirectRegisterOperand class]], nil);
	STAssertTrue(s.secondOperand.nextWord == 0, nil);
}

- (void)testParseCalledWithSetSPRegisterWithLabelRefGenertesCorrectStatments
{
	NSString *code = @"SET PC, crash";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 1, nil);

	Statment *s = [p.statments lastObject];

	STAssertTrue(s.opcode == OP_SET, nil);
	STAssertTrue([s.menemonic isEqualToString:@"SET"], nil);
	STAssertTrue([s.firstOperand isKindOfClass:[ProgramCounterOperand class]], nil);
	STAssertTrue([s.secondOperand isKindOfClass:[NextWordOperand class]], nil);
	STAssertTrue([s.secondOperand.label isEqualToString:@"crash"], nil);
	STAssertTrue(s.secondOperand.nextWord == 0, nil);
}

- (void)testParseCalledWithJSRandLabelRefGenertesCorrectStatments
{
	NSString *code = @"JSR testsub";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 1, nil);

	Statment *s = [p.statments lastObject];

	STAssertTrue(s.opcode == 0, nil);
	STAssertTrue(s.opcodeNonBasic == OP_JSR, nil);
	STAssertTrue([s.menemonic isEqualToString:@"JSR"], nil);
	STAssertTrue([s.firstOperand isKindOfClass:[NextWordOperand class]], nil);
	STAssertTrue([s.firstOperand.label isEqualToString:@"testsub"], nil);
	STAssertTrue(s.firstOperand.nextWord == 0, nil);
}

- (void)testParseCalledWithInvalidInstructionThrows
{
	NSString *code = @"JSM testsub";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
													 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	p.didFinishParsingWithError = ^(NSString *message)
	{
		STAssertTrue([message isEqualToString:@"Expected INSTRUCTION at line 1:3 found 'JSM'"], nil);
	};

	[p parseSource:code withLexer:lexer];
}

- (void)testParseCalledWithInvalidOperandThrows
{
	NSString *code = @"JSR \"testsub\"";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
														 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];

	p.didFinishParsingWithError = ^(NSString *message)
	{
		STAssertTrue([message isEqualToString:@"Expected operand at line 1:13 found '\"testsub\"'"], nil);
	};

	[p parseSource:code withLexer:lexer];
}

- (void)testParseCalledWithUnclosedBracketThrows
{
	NSString *code = @"SET [0x1000, 0x20";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
															 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];

	p.didFinishParsingWithError = ^(NSString *message)
	{
		STAssertTrue([message isEqualToString:@"Expected CLOSEBRACKET or PLUS at line 1:12 found ','"], nil);
	};

	[p parseSource:code withLexer:lexer];
}

- (void)testParseCalledWithNotchSampleGeneratesCorrectNumberOfStatments
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
    :loop         SET [0x2000+I], [A]      ; 2161 2000\n\
    SUB I, 1                 ; 8463\n\
    IFN I, 0                 ; 806d\n\
    SET PC, loop             ; 7dc1 000d [*]\n\
    \n\
    ; Call a subroutine\n\
    SET X, 0x4               ; 9031\n\
    JSR testsub              ; 7c10 0018 [*]\n\
    SET PC, crash            ; 7dc1 001a [*]\n\
    \n\
    :testsub      SHL X, 4   ; 9037\n\
    SET PC, POP              ; 61c1\n\
    \n\
    ; Hang forever. X should now be 0x40 if everything went right.\n\
    :crash        SET PC, crash            ; 7dc1 001a [*]\n\
    \n\
    ; [*]: Note that these can be one word shorter and one cycle faster by using the short form (0x00-0x1f) of literals,\n\
    ;      but my assembler doesn't support short form labels yet.";

	Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
														 consumeTokenStrategy:[[ConsumeToken alloc] init]];

	Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
	[p parseSource:code withLexer:lexer];

	STAssertTrue([p.statments count] == 17, nil);
}


@end
