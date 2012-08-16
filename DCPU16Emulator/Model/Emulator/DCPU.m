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

#import "DCPU.h"
#import "CPUInstruction.h"
#import "InstructionBuilder.h"
#import "InstructionOperandFactory.h"

@interface DCPU ()
{
	BOOL programCounterChanged;
}

@property(nonatomic, strong) InstructionBuilder *instructionBuilder;
@property(nonatomic, strong) id <InstructionOperandFactoryProtocol> operandFactory;
@property(nonatomic, strong, readwrite) Memory *memory;

@end

@implementation DCPU

@synthesize memory;
@synthesize operandFactory;
@synthesize instructionBuilder;
@synthesize ignoreNextInstruction;

- (id)initWithProgram:(NSArray *)program
{
	self = [super init];

	self.memory = [[Memory alloc] init];
	self.operandFactory = [[InstructionOperandFactory alloc] init];
	self.instructionBuilder = [[InstructionBuilder alloc] initWithInstructionOperandFactory:operandFactory];

	[self.memory load:program];

	return self;
}

- (BOOL)executeInstruction
{
	if([self.memory peekInstructionAtProgramCounter] == 0x0)
	{
		return false;
	}

	ushort rawInstruction = (ushort) [self.memory readInstructionAtProgramCounter];
	CPUInstruction *instruction = [self.instructionBuilder buildFromMachineCode:rawInstruction usingCpuState:self];

	if(!self.ignoreNextInstruction)
	{
		[instruction execute];
	}
	else
	{
		[instruction noOp];
		self.ignoreNextInstruction = NO;
	}

	if(!programCounterChanged)
	{
		[self incrementProgramCounter];
	}
	else
	{
		programCounterChanged = NO;
	}

	return YES;
}

- (int)programCounter
{
	return [self.memory getProgramCounter];
}

- (void)setProgramCounter:(int)value
{
	programCounterChanged = YES;
	[self.memory setProgramCounter:value];
}

- (int)stackPointer
{
	return [self.memory getStacPointer];
}

- (void)setStackPointer:(int)value
{
	[self.memory setStackPointer:value];
}

- (int)overflow
{
	return [self.memory getOverflow];
}

- (void)setOverflow:(int)value
{
	[self.memory setOverflow:value];
}

- (int)readGeneralPurposeRegisterValue:(int)reg;
{
	return [self.memory getValueForRegister:reg];
}

- (void)writeGeneralPurposeRegister:(int)reg withValue:(ushort)value
{
	[self.memory setValueForGeneralRegister:reg value:value];
}

- (int)readMemoryValueAtAddress:(int)address
{
	return [self.memory getMemoryValueAtIndex:address];
}

- (void)writeMemoryAtAddress:(int)address withValue:(ushort)value
{
	[self.memory setMemoryValue:value atIndex:address];
}

- (void)incrementProgramCounter
{
	[self.memory incrementProgramCounter];
}

- (void)incrementStackPointer
{
	[self.memory incrementStackPointer:1];
}

- (void)decrementStackPointer
{
	[self.memory incrementStackPointer:-1];
}

@end
