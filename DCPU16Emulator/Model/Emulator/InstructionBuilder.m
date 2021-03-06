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

#import "InstructionBuilder.h"
#import "Statment.h"
#import "Add.h"
#import "And.h"
#import "Bor.h"
#import "Div.h"
#import "Ifb.h"
#import "Ife.h"
#import "Ifg.h"
#import "Ifn.h"
#import "Jsr.h"
#import "Mod.h"
#import "Mul.h"
#import "Set.h"
#import "Shl.h"
#import "Shr.h"
#import "Sub.h"
#import "Xor.h"

typedef CPUInstruction *(^creationStrategy)();

@interface InstructionBuilder ()
{
	CPUOperation *operationA;
	CPUOperation *operationB;
	short opcode;
}

@property(nonatomic, strong) id <InstructionOperandFactoryProtocol> operandFactory;
@property(nonatomic, strong) NSDictionary *instructionMapper;


@end

@implementation InstructionBuilder

@synthesize operandFactory;
@synthesize instructionMapper;

- (id)initWithInstructionOperandFactory:(id <InstructionOperandFactoryProtocol>)factory
{
	self = [super init];
    
	self.operandFactory = factory;
    
	self.instructionMapper = @{
        @(OP_SET): (Set *) ^()
        {
            return [[Set alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_ADD): (Add *) ^()
        {
            return [[Add alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_SUB): (Sub *) ^()
        {
            return [[Sub alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_MUL): (Mul *) ^()
        {
            return [[Mul alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_DIV): (Div *) ^()
        {
            return [[Div alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_MOD): (Mod *) ^()
        {
            return [[Mod alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_SHL): (Shl *) ^()
        {
            return [[Shl alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_SHR): (Shr *) ^()
        {
            return [[Shr alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_AND): (And *) ^()
        {
            return [[And alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_BOR): (Bor *) ^()
        {
            return [[Bor alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_XOR): (Xor *) ^()
        {
            return [[Xor alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_IFE): (Ife *) ^()
        {
            return [[Ife alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_IFN): (Ifn *) ^()
        {
            return [[Ifn alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_IFG): (Ifg *) ^()
        {
            return [[Ifg alloc] initWithOperationA:operationA andOperationB:operationB];
        },
        @(OP_IFB): (Ifb *) ^()
        {
            return [[Ifb alloc] initWithOperationA:operationA andOperationB:operationB];
        }
    };
    
	return self;
}

- (CPUInstruction *)buildFromMachineCode:(ushort)code usingCpuState:(id <DCPUProtocol>)cpuStateOperations
{
	opcode = code & OpMask;
    
	if(opcode == 0)
	{
		ushort op = (code >> OperandAShift) & OperandAMask;
        
		if(op == 0x01)
		{
			ushort operandValue = (code >> OperandBShift) & OperandBMask;
            
			operationA = [[CPUOperation alloc] initWithOperand:[self.operandFactory createFromInstructionOperandValue:operandValue] cpuStateOperations:cpuStateOperations];
			operationB = nil;
            
			CPUInstruction *jsrInstruction = [[Jsr alloc] initWithOperationA:operationA andOperationB:operationB];
            
			return jsrInstruction;
		}
        
		return nil;
	}
    
	ushort operandAValue = (ushort) ((code >> OperandAShift) & OperandAMask);
	ushort operandBValue = (ushort) ((code >> OperandBShift) & OperandBMask);
    
	operationA = [[CPUOperation alloc] initWithOperand:[self.operandFactory createFromInstructionOperandValue:operandAValue] cpuStateOperations:cpuStateOperations];
	operationB = [[CPUOperation alloc] initWithOperand:[self.operandFactory createFromInstructionOperandValue:operandBValue] cpuStateOperations:cpuStateOperations];
    
	creationStrategy creator = [instructionMapper objectForKey:[NSNumber numberWithInt:opcode]];
    
	CPUInstruction *instruction = creator();
    
	return instruction;
}

@end
