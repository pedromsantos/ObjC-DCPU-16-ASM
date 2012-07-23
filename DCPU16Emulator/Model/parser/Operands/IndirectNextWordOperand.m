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

#import "IndirectNextWordOperand.h"

@implementation IndirectNextWordOperand

- (ushort)read
{
    return (ushort) [self.cpuOperations readMemoryValueAtAddress:self.nextWord];
}

- (void)writeValue:(ushort)value
{
    [self.cpuOperations writeMemoryAtAddress:self.nextWord withValue:value];
}

- (void)process
{
    [self.cpuOperations incrementProgramCounter];
    int programCounter = [self.cpuOperations programCounter];
    self.nextWord = (uint16_t) [self.cpuOperations readMemoryValueAtAddress:programCounter];
}

- (int)assembleWithShift:(int)shift
{
    if ((self.nextWord <= OPERAND_LITERAL_MAX) && !([self.label length] > 0))
    {
        return (self.nextWord + OPERAND_LITERAL_OFFSET) << shift;
    }
    else
    {
        return O_INDIRECT_NEXT_WORD << shift;
    }
}

@end
