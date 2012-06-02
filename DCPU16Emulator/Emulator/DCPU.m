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
#import "Parser.h"

@implementation DCPU

@synthesize memory;

- (id)initWithProgram:(NSArray*)program
{
    self = [super init];
    
    self.memory = [[Memory alloc] init];
    
    for (int i = 0; i < [program count]; i++) 
    {
        [self.memory setMemoryValue:[[program objectAtIndex:i] intValue] atIndex:i];
    }
    
    return self;
}

- (BOOL)step
{
    if ([self.memory peekInstructionAtProgramCounter] == 0x0) 
    {
        return false; 
    }
    
    int instruction = [self.memory readInstructionAtProgramCounter];
    int opcode =  instruction &  OP_MASK;
    int firstOperandValue  = (instruction >> A_SHIFT) & A_MASK;
    int secondOperandValue  = (instruction >> B_SHIFT) & B_MASK;

    if (opcode == 0) 
    {
        switch (firstOperandValue) 
        {
            case 0x01:
            {

                firstOperandValue = [self processOperand:secondOperandValue];
                [self.memory stackPush:[self.memory peekInstructionAtProgramCounter]];
                [self.memory setProgramCounter:firstOperandValue];
                break;
            }
            default:
            {
                NSLog(@"0x0000: Illegal operation '%x'", firstOperandValue);
                return NO;
            }
        }
    }
    else 
    {
        firstOperandValue = [self processOperand:firstOperandValue];
        NSString* fisrtOperandState = [operandState copy];
        secondOperandValue = [self processOperand:secondOperandValue];
        NSString* secondOperandState = [operandState copy];
        
        switch (opcode) 
        {
            case OP_SET: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_ADD: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 += op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_SUB: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 -= op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_MUL: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 *= op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_DIV: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 /= op2; }
                              usingOperand1AtAddress:firstOperandValue 
                                        inMemoryArea:fisrtOperandState
                                andOperand2AtAddress:secondOperandValue 
                                        inMemoryArea:secondOperandState
                                           toAddress:firstOperandValue 
                                        inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_MOD: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 %= op2; }
                              usingOperand1AtAddress:firstOperandValue 
                                        inMemoryArea:fisrtOperandState
                                andOperand2AtAddress:secondOperandValue 
                                        inMemoryArea:secondOperandState
                                           toAddress:firstOperandValue 
                                        inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_SHL: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 <<= op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_SHR: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ int temp = op1 >>= op2; return temp &= SHORT_MASK; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_AND: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 &= op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_BOR: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 |= op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_XOR: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 ^= op2; }
                           usingOperand1AtAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState
                             andOperand2AtAddress:secondOperandValue 
                                     inMemoryArea:secondOperandState
                                        toAddress:firstOperandValue 
                                     inMemoryArea:fisrtOperandState];
                break;
            }
            case OP_IFE: 
            {
                if([memory getMemoryValueAtIndex:firstOperandValue] != [memory getMemoryValueAtIndex:secondOperandValue])
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            case OP_IFN: 
            {
                if([memory getMemoryValueAtIndex:firstOperandValue] == [memory getMemoryValueAtIndex:secondOperandValue])
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            case OP_IFG: 
            {
                if([memory getMemoryValueAtIndex:firstOperandValue] > [memory getMemoryValueAtIndex:secondOperandValue])
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            case OP_IFB:
            {
                if(([memory getMemoryValueAtIndex:firstOperandValue] & [memory getMemoryValueAtIndex:secondOperandValue]) == 0)
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            default:
            {
                NSLog(@"0x0000: Illegal operation '%x'", opcode);
                return NO;
            }
        }
        
        if (opcode > 0x1 && opcode < 0x9 && opcode != 0x6)
        {
            //[self.ram setOverflowRegisterToValue:([ram getMemoryValueAtIndex:a] >> SHORT_SHIFT) & SHORT_MASK];
        }
    }
    
    return YES;
}

- (int)processOperand:(int)code 
{
    operandState = nil;
    
    if (code < 0x08) 
    {
        operandState = REG;
        return code;
    } 
    else if (code < 0x10) 
    {
        return [self.memory getValueForRegister:code % NUM_REGISTERS];
    } 
    else if (code < 0x18) 
    {
        operandState = MEM;
        return ([memory readInstructionAtProgramCounter] + [memory getValueForRegister:code % NUM_REGISTERS]) & SHORT_MASK;
    }
    else if (code == 0x18)
    {
        operandState = MEM;
        return [memory readInstructionAtStackPointer];
    }
    else if (code == 0x19)
    {
        operandState = MEM;
        return [memory peekInstructionAtStackPointer];
    }
    else if (code == 0x1A)
    {
        operandState = MEM;
        return [memory decrementAndReadInstructionAtStackPointer];
    }
    else if (code == 0x1B)
    {
        operandState = SP;
        return [memory decrementAndReadInstructionAtStackPointer];
    }
    else if (code == 0x1C)
    {
        operandState = PC;
        return [memory readInstructionAtProgramCounter];
    }
    else if (code == 0x1D)
    {
        operandState = OV;
        return 0;
    }
    else if (code == 0x1E)
    {
        operandState = MEM;
        return [memory readInstructionAtProgramCounter];
    }
    else if (code == 0x1F)
    {
        operandState = PC;
        return [memory readInstructionAtProgramCounter];
    }
    
    operandState = LIT;
    //[ram setMemoryValue:code atIndex:(code - 0x20) % NUM_ITERALS inMemoryArea:LIT];
    return (code - 0x20) % NUM_ITERALS;
}

- (int)getValueForRegister:(int)reg
{
    return [self.memory getValueForRegister:reg];
}

- (int)getValueForMemory:(int)address
{
    return [self.memory getMemoryValueAtIndex:address];
}

- (int)peekInstructionAtProgramCounter
{
    return [self.memory peekInstructionAtProgramCounter];
}

- (int)getProgramCounter
{
    return [self.memory getProgramCounter];
}

@end
