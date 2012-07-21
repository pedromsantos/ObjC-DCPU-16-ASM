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

#import "IndirectNextWordOffsetOperand.h"

@implementation IndirectNextWordOffsetOperand

- (ushort)read
{
    ushort value = [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
    
    return [self.cpuOperations readMemoryValueAtAddress:self.nextWord + value] & SHORT_MASK;
}

- (void)writeValue:(ushort)value
{
    [self.cpuOperations writeMemoryAtAddress:(self.nextWord + self.registerValue) & SHORT_MASK withValue:value];
}

- (void)process
{
    [self.cpuOperations incrementProgramCounter];
    int programCounter = [self.cpuOperations programCounter];
    self.nextWord = [self.cpuOperations readMemoryValueAtAddress:programCounter];
    self.registerValue = [self.cpuOperations readGeneralPursoseRegisterValue:self.value % NUMBER_OF_REGISTERS];
}

- (int)assembleWithShift:(int)shift
{
    return (O_INDIRECT_NEXT_WORD_OFFSET + self.registerValue) << shift;
}

@end
