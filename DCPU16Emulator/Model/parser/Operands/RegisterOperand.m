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

#import "RegisterOperand.h"

@implementation RegisterOperand

- (ushort)read
{
    return [self.cpuOperations readGeneralPursoseRegisterValue:self.registerValue];
}

- (void)writeValue:(ushort)value
{
    [self.cpuOperations writeGeneralPursoseRegister:self.registerValue withValue:value];
}

- (int)assembleWithShift:(int)shift
{
    return (O_REG + self.registerValue) << shift;
}

- (void)setRegisterValueForName:(NSString*)name
{
    if ([name isEqualToString:@"A"]) self.registerValue = REG_A;
    else if ([name isEqualToString:@"B"]) self.registerValue = REG_B;
    else if ([name isEqualToString:@"C"]) self.registerValue = REG_C;
    else if ([name isEqualToString:@"X"]) self.registerValue = REG_X;
    else if ([name isEqualToString:@"Y"]) self.registerValue = REG_Y;
    else if ([name isEqualToString:@"Z"]) self.registerValue = REG_Z;
    else if ([name isEqualToString:@"I"]) self.registerValue = REG_I;
    else if ([name isEqualToString:@"J"]) self.registerValue = REG_J;
    else @throw @"Invalid register.";
}

+ (enum operand_type)operandTypeForName:(NSString*)name
{
    if ([name length] == 1 && (
                               [name isEqualToString: @"A"] || [name isEqualToString: @"B"]  || [name isEqualToString: @"C"]  ||
                               [name isEqualToString: @"X"] || [name isEqualToString: @"Y"]  || [name isEqualToString: @"Z"]  ||
                               [name isEqualToString: @"I"] || [name isEqualToString: @"J"] )) return O_REG;
    
    if ([name isEqualToString: @"PC"]) return O_PC;
    if ([name isEqualToString: @"SP"]) return O_SP;
    if ([name isEqualToString: @"O"]) return O_O;
    
    if ([name isEqualToString: @"POP"]) return O_POP;
    if ([name isEqualToString: @"PEEK"]) return O_PEEK;
    if ([name isEqualToString: @"PUSH"]) return O_PUSH;
    
    return O_NEXT_WORD;
}

@end
