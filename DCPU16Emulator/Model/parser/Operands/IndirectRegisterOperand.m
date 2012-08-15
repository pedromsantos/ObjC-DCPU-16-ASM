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

#import "IndirectRegisterOperand.h"

@implementation IndirectRegisterOperand

- (ushort)read
{
    ushort address = (ushort) [self.cpuOperations readGeneralPurposeRegisterValue:self.value % NUMBER_OF_REGISTERS];
    ushort value = (ushort) [self.cpuOperations readMemoryValueAtAddress:address];
    return value;
}

- (void)writeValue:(ushort)value
{
    ushort address = (ushort) [self.cpuOperations readGeneralPurposeRegisterValue:self.value % NUMBER_OF_REGISTERS];
    [self.cpuOperations writeMemoryAtAddress:address withValue:value];
}

- (int)assembleWithShift:(int)shift
{
    return (O_INDIRECT_REG + self.registerValue) << shift;
}

@end
