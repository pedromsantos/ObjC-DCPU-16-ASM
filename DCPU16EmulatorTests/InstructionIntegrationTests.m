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

#import "InstructionIntegrationTests.h"
#import "InstructionBuilder.h"
#import "InstructionOperandFactory.h"
#import "Parser.h"
#import "Assembler.h"
#import "DCPU.h"
#import "Set.h"
#import "Shl.h"
#import "Sub.h"
#import "Lexer.h"
#import "IgnoreWhiteSpaceTokenStrategy.h"
#import "ConsumeToken.h"
#import "OperandFactory.h"

@implementation InstructionIntegrationTests


@synthesize expectedInstructionType;
@synthesize inputValue;
@synthesize outputValue;
@synthesize inputCode;
@synthesize address;

- (id)initWithInvocation:(NSInvocation *)anInvocation inputValue:(ushort)value expectedInstructionType:(Class)expectedType
{
	self = [super initWithInvocation:anInvocation];

	if(self)
	{
		self.expectedInstructionType = expectedType;
		self.inputValue = value;
	}

	return self;
}

- (id)initWithInvocation:(NSInvocation *)anInvocation inputCode:(NSString *)code expectedOutput:(ushort)output atAddress:(ushort)addrs
{
	self = [super initWithInvocation:anInvocation];

	if(self)
	{
		self.outputValue = output;
		self.inputCode = code;
		self.address = addrs;
	}

	return self;
}

- (void)testBuildWhenCalledForRawInstructionBuildsExpectedInstructionInstance
{
	if(self.expectedInstructionType != nil)
	{
		InstructionOperandFactory *factory = [[InstructionOperandFactory alloc] init];
		InstructionBuilder *builder = [[InstructionBuilder alloc] initWithInstructionOperandFactory:factory];

		CPUInstruction *instruction = [builder buildFromMachineCode:self.inputValue usingCpuState:nil];

		STAssertTrue([instruction isKindOfClass:self.expectedInstructionType], nil);
	}
}

- (void)testExecutingInstructionGeneratesExpectedOutput
{
	if(self.inputCode != nil)
	{
		Lexer *lexer = [[Lexer alloc] initWithIgnoreTokenStrategy:[[IgnoreWhiteSpaceTokenStrategy alloc] init]
															 consumeTokenStrategy:[[ConsumeToken alloc] init]];

		Parser *p = [[Parser alloc] initWithOperandFactory:[[OperandFactory alloc] init]];
		[p parseSource:self.inputCode withLexer:lexer];

		Assembler *assembler = [[Assembler alloc] init];
		[assembler assembleStatments:p.statments];
		DCPU *emulator = [[DCPU alloc] initWithProgram:(assembler.program)];

		BOOL executed = true;

		while(executed)
		{
			executed = [emulator executeInstruction];
		}

		ushort result = (ushort) [emulator readGeneralPurposeRegisterValue:self.address];
		STAssertEquals(result, self.outputValue, nil);
	}
}

+ (void)addTestCreateWhenCalledWithValueinput:(ushort)inputValue createsExpectedInstructionType:(Class)expectedInstruction
								  toTestSuite:(SenTestSuite *)testSuite
{
	NSArray *testInvocations = [self testInvocations];

	for(NSInvocation *testInvocation in testInvocations)
	{
		SenTestCase *test = [[InstructionIntegrationTests alloc]
														  initWithInvocation:testInvocation
																  inputValue:inputValue
													 expectedInstructionType:expectedInstruction];

		[testSuite addTest:test];
	}
}

+ (void)addTestCreateWhenCalledWithCode:(NSString *)code expectedOutput:(ushort)expectedOutput atAddress:(ushort)address
							toTestSuite:(SenTestSuite *)testSuite
{
	NSArray *testInvocations = [self testInvocations];

	for(NSInvocation *testInvocation in testInvocations)
	{
		SenTestCase *test = [[InstructionIntegrationTests alloc]
														  initWithInvocation:testInvocation
																   inputCode:code
															  expectedOutput:expectedOutput
																   atAddress:address];

		[testSuite addTest:test];
	}
}

+ (id)defaultTestSuite
{
	SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];

	[self addTestCreateWhenCalledWithValueinput:0x7c01 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0x7de1 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0xA861 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0x9031 createsExpectedInstructionType:[Set class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0x8463 createsExpectedInstructionType:[Sub class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0x8463 createsExpectedInstructionType:[Sub class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0x7803 createsExpectedInstructionType:[Sub class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithValueinput:0x9037 createsExpectedInstructionType:[Shl class] toTestSuite:testSuite];

	NSArray *registerNames = [NSArray arrayWithObjects:@"A", @"B", @"C", @"I", @"J", @"X", @"Y", @"Z", nil];
	ushort registerIds[] = { REG_A, REG_B, REG_C, REG_I, REG_J, REG_X, REG_Y, REG_Z };
	int regId = 0;

	ushort output = 0x10;
	NSString *codeFormat = @"ADD %@, 0x10";
	for(NSString *registerName in registerNames)
	{
		NSString *code = [NSString stringWithFormat:codeFormat, registerName];
		[self addTestCreateWhenCalledWithCode:code expectedOutput:output atAddress:registerIds[regId] toTestSuite:testSuite];
		regId++;
	}

	regId = 0;
	output = 0x4 / 0x2;
	codeFormat = @"SET %@, 0x4\nDIV %@, 0x2";
	for(NSString *registerName in registerNames)
	{
		NSString *code = [NSString stringWithFormat:codeFormat, registerName, registerName];
		[self addTestCreateWhenCalledWithCode:code expectedOutput:output atAddress:registerIds[regId] toTestSuite:testSuite];
		regId++;
	}

	regId = 0;
	output = 0x5 % 0x2;
	codeFormat = @"SET %@, 0x5\nMOD %@, 0x2";
	for(NSString *registerName in registerNames)
	{
		NSString *code = [NSString stringWithFormat:codeFormat, registerName, registerName];
		[self addTestCreateWhenCalledWithCode:code expectedOutput:output atAddress:registerIds[regId] toTestSuite:testSuite];
		regId++;
	}

	regId = 0;
	output = 0x2 * 0x2;
	codeFormat = @"SET %@, 0x2\nMUL %@, 0x2";
	for(NSString *registerName in registerNames)
	{
		NSString *code = [NSString stringWithFormat:codeFormat, registerName, registerName];
		[self addTestCreateWhenCalledWithCode:code expectedOutput:output atAddress:registerIds[regId] toTestSuite:testSuite];
		regId++;
	}

	regId = 0;
	output = 0x2 << 0x2;
	codeFormat = @"SET %@, 0x2\nSHL %@, 0x2";
	for(NSString *registerName in registerNames)
	{
		NSString *code = [NSString stringWithFormat:codeFormat, registerName, registerName];
		[self addTestCreateWhenCalledWithCode:code expectedOutput:output atAddress:registerIds[regId] toTestSuite:testSuite];
		regId++;
	}

	regId = 0;
	output = 0x2 >> 0x2;
	codeFormat = @"SET %@, 0x2\nSHR %@, 0x2";
	for(NSString *registerName in registerNames)
	{
		NSString *code = [NSString stringWithFormat:codeFormat, registerName, registerName];
		[self addTestCreateWhenCalledWithCode:code expectedOutput:output atAddress:registerIds[regId] toTestSuite:testSuite];
		regId++;
	}

	[self addTestCreateWhenCalledWithCode:@"SET A, 0x1\nAND A, 0x1" expectedOutput:0x1 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET B, 0x1\nAND B, 0x0" expectedOutput:0x0 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET C, 0x1\nAND C, 0x1" expectedOutput:0x1 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET I, 0x1\nAND I, 0x0" expectedOutput:0x0 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET J, 0x1\nAND J, 0x1" expectedOutput:0x1 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET X, 0x1\nAND X, 0x0" expectedOutput:0x0 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Y, 0x1\nAND Y, 0x1" expectedOutput:0x1 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Z, 0x1\nAND Z, 0x0" expectedOutput:0x0 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET A, 0x1\nBOR A, 0x1" expectedOutput:0x1 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET B, 0x1\nBOR B, 0x0" expectedOutput:0x1 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET C, 0x1\nBOR C, 0x1" expectedOutput:0x1 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET I, 0x1\nBOR I, 0x0" expectedOutput:0x1 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET J, 0x1\nBOR J, 0x1" expectedOutput:0x1 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET X, 0x1\nBOR X, 0x0" expectedOutput:0x1 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Y, 0x1\nBOR Y, 0x1" expectedOutput:0x1 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Z, 0x1\nBOR Z, 0x0" expectedOutput:0x1 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET A, 0x1\nXOR A, 0x1" expectedOutput:0x0 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET B, 0x1\nXOR B, 0x0" expectedOutput:0x1 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET C, 0x1\nXOR C, 0x1" expectedOutput:0x0 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET I, 0x1\nXOR I, 0x0" expectedOutput:0x1 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET J, 0x1\nXOR J, 0x1" expectedOutput:0x0 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET X, 0x1\nXOR X, 0x0" expectedOutput:0x1 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Y, 0x1\nXOR Y, 0x1" expectedOutput:0x0 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Z, 0x1\nXOR Z, 0x0" expectedOutput:0x1 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET A, [0x1000]" expectedOutput:0x10 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET B, [0x1000]" expectedOutput:0x10 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET C, [0x1000]" expectedOutput:0x10 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET I, [0x1000]" expectedOutput:0x10 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET J, [0x1000]" expectedOutput:0x10 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET X, [0x1000]" expectedOutput:0x10 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET Y, [0x1000]" expectedOutput:0x10 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x10\nSET Z, [0x1000]" expectedOutput:0x10 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET A, [0x1000]" expectedOutput:0x30 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET B, [0x1000]" expectedOutput:0x30 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET C, [0x1000]" expectedOutput:0x30 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET I, [0x1000]" expectedOutput:0x30 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET J, [0x1000]" expectedOutput:0x30 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET X, [0x1000]" expectedOutput:0x30 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET Y, [0x1000]" expectedOutput:0x30 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET [0x1000], 0x30\nSET Z, [0x1000]" expectedOutput:0x30 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET A, 0x10\nSET [0x1000+A], 0x10\nSET A, [0x1000+A]" expectedOutput:0x10 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET B, 0x10\nSET [0x1000+B], 0x10\nSET B, [0x1000+B]" expectedOutput:0x10 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET C, 0x10\nSET [0x1000+C], 0x10\nSET C, [0x1000+C]" expectedOutput:0x10 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET I, 0x10\nSET [0x1000+I], 0x10\nSET I, [0x1000+I]" expectedOutput:0x10 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET J, 0x10\nSET [0x1000+J], 0x10\nSET J, [0x1000+J]" expectedOutput:0x10 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET X, 0x10\nSET [0x1000+X], 0x10\nSET X, [0x1000+X]" expectedOutput:0x10 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Y, 0x10\nSET [0x1000+Y], 0x10\nSET Y, [0x1000+Y]" expectedOutput:0x10 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Z, 0x10\nSET [0x1000+Z], 0x10\nSET Z, [0x1000+Z]" expectedOutput:0x10 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET A, 0x10\nSET [0x1000+A], 0x30\nSET A, [0x1000+A]" expectedOutput:0x30 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET B, 0x10\nSET [0x1000+B], 0x30\nSET B, [0x1000+B]" expectedOutput:0x30 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET C, 0x10\nSET [0x1000+C], 0x30\nSET C, [0x1000+C]" expectedOutput:0x30 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET I, 0x10\nSET [0x1000+I], 0x30\nSET I, [0x1000+I]" expectedOutput:0x30 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET J, 0x10\nSET [0x1000+J], 0x30\nSET J, [0x1000+J]" expectedOutput:0x30 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET X, 0x10\nSET [0x1000+X], 0x30\nSET X, [0x1000+X]" expectedOutput:0x30 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Y, 0x10\nSET [0x1000+Y], 0x30\nSET Y, [0x1000+Y]" expectedOutput:0x30 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Z, 0x10\nSET [0x1000+Z], 0x30\nSET Z, [0x1000+Z]" expectedOutput:0x30 atAddress:REG_Z toTestSuite:testSuite];

	[self addTestCreateWhenCalledWithCode:@"SET A, 0x1000\nSET [A], 0x30\nSET A, [A]" expectedOutput:0x30 atAddress:REG_A toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET B, 0x1000\nSET [B], 0x30\nSET B, [B]" expectedOutput:0x30 atAddress:REG_B toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET C, 0x1000\nSET [C], 0x30\nSET C, [C]" expectedOutput:0x30 atAddress:REG_C toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET I, 0x1000\nSET [I], 0x30\nSET I, [I]" expectedOutput:0x30 atAddress:REG_I toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET J, 0x1000\nSET [J], 0x30\nSET J, [J]" expectedOutput:0x30 atAddress:REG_J toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET X, 0x1000\nSET [X], 0x30\nSET X, [X]" expectedOutput:0x30 atAddress:REG_X toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Y, 0x1000\nSET [Y], 0x30\nSET Y, [Y]" expectedOutput:0x30 atAddress:REG_Y toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithCode:@"SET Z, 0x1000\nSET [Z], 0x30\nSET Z, [Z]" expectedOutput:0x30 atAddress:REG_Z toTestSuite:testSuite];

	return testSuite;
}

@end
