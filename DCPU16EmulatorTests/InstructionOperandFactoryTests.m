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

#import "RegisterOperand.h"
#import "PopOperand.h"
#import "PeekOperand.h"
#import "PushOperand.h"
#import "StackPointerOperand.h"
#import "ProgramCounterOperand.h"
#import "OverflowOperand.h"
#import "IndirectNextWordOperand.h"
#import "NextWordOperand.h"
#import "LiteralOperand.h"
#import "IndirectRegisterOperand.h"
#import "InstructionOperandFactory.h"
#import "InstructionOperandFactoryTests.h"

@implementation InstructionOperandFactoryTests

@synthesize expectedOperand;
@synthesize inputValue;

- (id)initWithInvocation:(NSInvocation *)anInvocation inputValue:(short)value expectedOperand:(Class)expectedOprnd
{
	self = [super initWithInvocation:anInvocation];

	if(self)
	{
		self.expectedOperand = expectedOprnd;
		self.inputValue = value;
	}

	return self;
}

- (void)testCreateWhenCalledWithOperandValueCreatesExpectedOperandType
{
	InstructionOperandFactory *factory = [[InstructionOperandFactory alloc] init];

	Operand *operand = [factory createFromInstructionOperandValue:(ushort) self.inputValue];

	STAssertEquals(self.expectedOperand, [operand class], nil);
}

+ (void)addTestCreateWhenCalledWithOperandValueinput:(short)inputValue createsExpectedOperandType:(Class)expectedOperand
										 toTestSuite:(SenTestSuite *)testSuite
{
	NSArray *testInvocations = [self testInvocations];

	for(NSInvocation *testInvocation in testInvocations)
	{
		SenTestCase *test = [[InstructionOperandFactoryTests alloc]
															 initWithInvocation:testInvocation
																	 inputValue:inputValue
																expectedOperand:expectedOperand];

		[testSuite addTest:test];
	}
}

+ (id)defaultTestSuite
{
	SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];

	[self addTestCreateWhenCalledWithOperandValueinput:REG_A createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_B createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_C createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_I createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_J createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_X createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_Y createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:REG_Z createsExpectedOperandType:[RegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_INDIRECT_REG createsExpectedOperandType:[IndirectRegisterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_POP createsExpectedOperandType:[PopOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_PEEK createsExpectedOperandType:[PeekOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_PUSH createsExpectedOperandType:[PushOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_SP createsExpectedOperandType:[StackPointerOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_PC createsExpectedOperandType:[ProgramCounterOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_O createsExpectedOperandType:[OverflowOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_INDIRECT_NEXT_WORD createsExpectedOperandType:[IndirectNextWordOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_NEXT_WORD createsExpectedOperandType:[NextWordOperand class] toTestSuite:testSuite];
	[self addTestCreateWhenCalledWithOperandValueinput:O_LITERAL createsExpectedOperandType:[LiteralOperand class] toTestSuite:testSuite];

	return testSuite;
}

@end
