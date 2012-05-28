/*
 * Copyright (C) 2012 Pedro Santos
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

#import "Emulator.h"

@implementation Emulator

@synthesize ram;

- (id)initWithProgram:(NSArray*)program
{
    self = [super init];
    
    self.ram = [[Ram alloc] init];
    
    for (int i = 0; i < NUM_ITERALS; i++) 
    {
        [self.ram setLiteral:i atIndex:i];
    }
    
    for (int i = 0; i < [program count]; i++) 
    {
        [self.ram setMemoryValue:[[program objectAtIndex:i] intValue] atIndex:i];
    }
    
    for (int i = 0; i < NUM_REGISTERS; i++) 
    {
        [self.ram setMemoryValue:0 atIndex:i inMemoryArea:REG];
    }
    
    return self;
}

- (BOOL)step
{
    if ([self.ram peekInstructionAtProgramCounter] == 0x0) 
    {
        return false; 
    }
    
    int code = [self.ram readInstructionAtProgramCounter];
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
                [self.ram stackPush:[self.ram peekInstructionAtProgramCounter]];
                [self.ram setProgramCounter:a];
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
        NSString* rpStateForOperand1 = rp;
        b = [self parseVar:b];
        NSString* rpStateForOperand2 = rp;
        
        switch (op) 
        {
            case 0x1: 
            {
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 += op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 -= op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 *= op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 <<= op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ int temp = op1 >>= op2; return temp &= SHORT_MASK; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 &= op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 |= op2; }
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
                [self.ram assignResultOfOperation:^(int op1, int op2){ return op1 ^= op2; }
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
                if([ram getMemoryValueAtIndex:a] != [ram getMemoryValueAtIndex:b])
                {
                    [ram incrementProgramCounter];
                }
                break;
            }
            case 0xD: 
            {
                if([ram getMemoryValueAtIndex:a] == [ram getMemoryValueAtIndex:b])
                {
                    [ram incrementProgramCounter];
                }
                break;
            }
            case 0xE: 
            {
                if([ram getMemoryValueAtIndex:a] > [ram getMemoryValueAtIndex:b])
                {
                    [ram incrementProgramCounter];
                }
                break;
            }
            case 0xF:
            {
                if(([ram getMemoryValueAtIndex:a] & [ram getMemoryValueAtIndex:b]) == 0)
                {
                    [ram incrementProgramCounter];
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
            [self.ram setOverflowRegisterToValue:([ram getMemoryValueAtIndex:a] >> SHORT_SHIFT) & SHORT_MASK];
        }
    }
    
    return YES;
}

- (int)parseVar:(int)code 
{
    if (code < 0x08) 
    {
        rp = REG;
        return code;
    } 
    else if (code < 0x10) 
    {
        rp = MEM;
        return [self.ram getValueForRegister:code % NUM_REGISTERS];
    } 
    else if (code < 0x18) 
    {
        return ([ram readInstructionAtStackPointer] + [ram getValueForRegister:code % NUM_REGISTERS]) & SHORT_MASK;
    }
    else if (code == 0x18)
    {
        rp = MEM;
        return [ram readInstructionAtStackPointer];
    }
    else if (code == 0x19)
    {
        rp = MEM;
        return [ram peekInstructionAtStackPointer];
    }
    else if (code == 0x1A)
    {
        rp = MEM;
        return [ram decrementAndReadInstructionAtStackPointer];
    }
    else if (code == 0x1B)
    {
        rp = SP;
        return 0;
    }
    else if (code == 0x1C)
    {
        rp = PC;
        return 0;
    }
    else if (code == 0x1D)
    {
        rp = OV;
        return 0;
    }
    else if (code == 0x1E)
    {
        rp = MEM;
        return [ram peekInstructionAtStackPointer];
    }
    else if (code == 0x1F)
    {
        rp = PC;
        [ram peekInstructionAtStackPointer];
        return 0;
    }
    
    rp = LIT;
    return (code - 0x20) % NUM_ITERALS;
}

- (int)getValueForRegister:(int)reg
{
    return [self.ram getValueForRegister:reg];
}

@end
