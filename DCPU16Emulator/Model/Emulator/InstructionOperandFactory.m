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

#import "InstructionOperandFactory.h"
#import "RegisterOperand.h"
#import "IndirectRegisterOperand.h"
#import "IndirectNextWordOffsetOperand.h"
#import "PopOperand.h"
#import "PeekOperand.h"
#import "PushOperand.h"
#import "StackPointerOperand.h"
#import "ProgramCounterOperand.h"
#import "OverflowOperand.h"
#import "IndirectNextWordOperand.h"
#import "NextWordOperand.h"
#import "LiteralOperand.h"
#import "NullOperand.h"

@interface InstructionOperandFactory()

- (Operand*)createOperandForValue:(ushort)operandValue;

@end

@implementation InstructionOperandFactory

- (id)init
{
    self = [super init];

    return self;
}

- (Operand*)createOperandForValue:(ushort)operandValue
{
    if(operandValue < O_INDIRECT_REG)
    {
        return [[RegisterOperand alloc] init];
    }
    else if(operandValue < O_INDIRECT_NEXT_WORD_OFFSET)
    {
        return [[IndirectRegisterOperand alloc] init];
    }
    else if(operandValue < O_POP)
    {
        return [[IndirectNextWordOffsetOperand alloc] init];
    }
    else if(operandValue == O_POP)
    {
        return [[PopOperand alloc] init];
    }
    else if(operandValue == O_PEEK)
    {
        return [[PeekOperand alloc] init];
    }
    else if(operandValue == O_PUSH)
    {
        return [[PushOperand alloc] init];
    }
    else if(operandValue == O_SP)
    {
        return [[StackPointerOperand alloc] init];
    }
    else if(operandValue == O_PC)
    {
        return [[ProgramCounterOperand alloc] init];
    }
    else if(operandValue == O_O)
    {
        return [[OverflowOperand alloc] init];
    }
    else if(operandValue == O_INDIRECT_NEXT_WORD)
    {
        return [[IndirectNextWordOperand alloc] init];
    }
    else if(operandValue == O_NEXT_WORD)
    {
        return [[NextWordOperand alloc] init];
    }
    else
    {
        return [[LiteralOperand alloc] init];
    }
}

- (Operand *)createFromInstructionOperandValue:(ushort)operandValue
{
    Operand* operand = [self createOperandForValue:operandValue];
    
    operand.value = operandValue;
    
    return operand;
}

@end
