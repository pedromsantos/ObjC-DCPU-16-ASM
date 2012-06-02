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

@implementation DCPU

@synthesize memory;

- (id)initWithProgram:(NSArray*)program
{
    self = [super init];
    
    self.memory = [[Memory alloc] init];
    
    for (int i = 0; i < NUM_ITERALS; i++) 
    {
        [self.memory setLiteral:i atIndex:i];
    }
    
    for (int i = 0; i < NUM_REGISTERS; i++) 
    {
        [self.memory setMemoryValue:0 atIndex:i inMemoryArea:REG];
    }
    
    for (int i = 0; i < MEMORY_SIZE; i++) 
    {
        [self.memory setMemoryValue:0 atIndex:i];
    }
    
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
    
    int code = [self.memory readInstructionAtProgramCounter];
    int op =  code &  OP_MASK;
    int a  = (code >> A_SHIFT) & A_MASK;
    int b  = (code >> B_SHIFT) & B_MASK;

    if (op == 0) 
    {
        switch (a) 
        {
            case 0x01:
            {

                a = [self parseVar:b];
                [self.memory stackPush:[self.memory peekInstructionAtProgramCounter]];
                [self.memory setProgramCounter:a];
                break;
            }
            default:
            {
                NSLog(@"0x0000: Illegal operation '%x'", a);
                return NO;
            }
        }
    }
    else 
    {
        a = [self parseVar:a];
        NSString* rpStateForOperand1 = [rp copy];
        b = [self parseVar:b];
        NSString* rpStateForOperand2 = [rp copy];
        
        switch (op) 
        {
            case 0x1: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0x2: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 += op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0x3: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 -= op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0x4: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 *= op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0x7: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 <<= op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0x8: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ int temp = op1 >>= op2; return temp &= SHORT_MASK; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0x9: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 &= op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0xA: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 |= op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0xB: 
            {
                [self.memory assignResultOfOperation:^(int op1, int op2){ return op1 ^= op2; }
                           usingOperand1AtAddress:a 
                                     inMemoryArea:rpStateForOperand1
                             andOperand2AtAddress:b 
                                     inMemoryArea:rpStateForOperand2
                                        toAddress:a 
                                     inMemoryArea:rpStateForOperand1];
                break;
            }
            case 0xC: 
            {
                if([memory getMemoryValueAtIndex:a] != [memory getMemoryValueAtIndex:b])
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            case 0xD: 
            {
                if([memory getMemoryValueAtIndex:a] == [memory getMemoryValueAtIndex:b])
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            case 0xE: 
            {
                if([memory getMemoryValueAtIndex:a] > [memory getMemoryValueAtIndex:b])
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            case 0xF:
            {
                if(([memory getMemoryValueAtIndex:a] & [memory getMemoryValueAtIndex:b]) == 0)
                {
                    [memory incrementProgramCounter];
                }
                break;
            }
            default:
            {
                NSLog(@"0x0000: Illegal operation '%x'", op);
                return NO;
            }
        }
        
        if (op > 0x1 && op < 0x9 && op != 0x6)
        {
            //[self.ram setOverflowRegisterToValue:([ram getMemoryValueAtIndex:a] >> SHORT_SHIFT) & SHORT_MASK];
        }
    }
    
    return YES;
}

- (int)parseVar:(int)code 
{
    rp = nil;
    
    if (code < 0x08) 
    {
        rp = REG;
        return code;
    } 
    else if (code < 0x10) 
    {
        return [self.memory getValueForRegister:code % NUM_REGISTERS];
    } 
    else if (code < 0x18) 
    {
        rp = MEM;
        return ([memory readInstructionAtProgramCounter] + [memory getValueForRegister:code % NUM_REGISTERS]) & SHORT_MASK;
    }
    else if (code == 0x18)
    {
        rp = MEM;
        return [memory readInstructionAtStackPointer];
    }
    else if (code == 0x19)
    {
        rp = MEM;
        return [memory peekInstructionAtStackPointer];
    }
    else if (code == 0x1A)
    {
        rp = MEM;
        return [memory decrementAndReadInstructionAtStackPointer];
    }
    else if (code == 0x1B)
    {
        rp = SP;
        return [memory decrementAndReadInstructionAtStackPointer];
    }
    else if (code == 0x1C)
    {
        rp = PC;
        return [memory readInstructionAtProgramCounter];
    }
    else if (code == 0x1D)
    {
        rp = OV;
        return 0;
    }
    else if (code == 0x1E)
    {
        rp = MEM;
        return [memory readInstructionAtProgramCounter];
    }
    else if (code == 0x1F)
    {
        rp = PC;
        return [memory readInstructionAtProgramCounter];
    }
    
    rp = LIT;
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
