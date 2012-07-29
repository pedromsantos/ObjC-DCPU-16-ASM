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

#import "CPUOperation.h"

@implementation CPUOperation

@synthesize operand;
@synthesize cpuOperations;

-(id)initWithOperand:(Operand*)oper cpuStateOperations:(id<DCPUProtocol>)cpuStateOperations
{
    self = [super init];
    
    self.operand = oper;
    self.cpuOperations = cpuStateOperations;
    
    return self;
}

- (ushort)read
{
    return [self.operand read];
}

- (void)write:(ushort)value
{
    @throw @"Invalid operation.";
}

- (void)setWrite:(ushort)value
{
    if (value > USHRT_MAX)
    {
        [self.cpuOperations setOverflow:0x0001];
    }
    else if (value < 0)
    {
        [self.cpuOperations setOverflow:USHRT_MAX];
    }

    [self.operand writeValue:value];
}

- (BOOL)ignoreInstruction
{
    return [self.cpuOperations ignoreNextInstruction];
}

- (void)setIgnoreInstruction:(BOOL)value
{
    [self.cpuOperations setIgnoreNextInstruction:value];
}

- (ushort)overflowRegister
{
    return (ushort) [self.cpuOperations overflow];
}

- (void)setOverflowRegister:(ushort)value
{
    [self.cpuOperations setOverflow:value];
}

- (void)process
{
    [self.operand process];
}

- (void)noOp
{
    [self.operand noOp];
}

- (void)jumpSubRoutine:(ushort)subRoutineAdress
{
    [self.cpuOperations decrementStackPointer];
    [self.cpuOperations writeMemoryAtAddress:[self.cpuOperations stackPointer] withValue:(ushort) [self.cpuOperations programCounter]];
    [self.cpuOperations setProgramCounter:subRoutineAdress];
}

@end
