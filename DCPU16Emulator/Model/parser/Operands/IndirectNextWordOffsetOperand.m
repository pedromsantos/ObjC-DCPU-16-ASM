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
	return (ushort) ([self.cpuOperations readMemoryValueAtAddress:self.nextWord + self.registerValue] & SHORT_MASK);
}

- (void)writeValue:(ushort)value
{
	ushort address = (self.nextWord + self.registerValue) & SHORT_MASK;
	[self.cpuOperations writeMemoryAtAddress:address withValue:value];
}

- (void)process
{
	[self.cpuOperations incrementProgramCounter];
	int programCounter = [self.cpuOperations programCounter];
	self.nextWord = (uint16_t) [self.cpuOperations readMemoryValueAtAddress:programCounter];
	ushort reg = self.value % NUMBER_OF_REGISTERS;
	self.registerValue = (enum operand_register_value) [self.cpuOperations readGeneralPurposeRegisterValue:reg];
}

- (int)assembleWithShift:(int)shift
{
	return (O_INDIRECT_NEXT_WORD_OFFSET + self.registerValue) << shift;
}

@end
