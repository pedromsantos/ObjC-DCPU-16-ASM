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
    ushort value = (ushort) [self.cpuOperations readGeneralPurposeRegisterValue:self.value];
    return value;
}

- (void)writeValue:(ushort)val
{
    [self.cpuOperations writeGeneralPurposeRegister:self.value withValue:val];
}

- (int)assembleWithShift:(int)shift
{
    return (O_REG + self.registerValue) << shift;
}

+ (NSString*)registerNameForIdentifier:(ushort)identifier
{
    if(identifier == REG_A) return @"A";
    if(identifier == REG_B) return @"B";
    if(identifier == REG_C) return @"C";
    if(identifier == REG_X) return @"X";
    if(identifier == REG_Y) return @"Y";
    if(identifier == REG_Z) return @"Z";
    if(identifier == REG_I) return @"I";
    if(identifier == REG_J) return @"J";
    
    return @"";
}

+ (int)registerIdentifierForName:(NSString *)name
{
    NSString *registerName = [name uppercaseString];
    
    if ([registerName isEqualToString:@"A"])
    {
        return REG_A;
    }
    else if ([registerName isEqualToString:@"B"])
    {
        return REG_B;
    }
    else if ([registerName isEqualToString:@"C"])
    {
        return REG_C;
    }
    else if ([registerName isEqualToString:@"X"])
    {
        return REG_X;
    }
    else if ([registerName isEqualToString:@"Y"])
    {
        return REG_Y;
    }
    else if ([registerName isEqualToString:@"Z"])
    {
        return REG_Z;
    }
    else if ([registerName isEqualToString:@"I"])
    {
        return REG_I;
    }
    else if ([registerName isEqualToString:@"J"])
    {
        return REG_J;
    }
    else if ([registerName isEqualToString:@"PC"])
    {
        return O_PC;
    }
    else if ([registerName isEqualToString:@"SP"])
    {
        return O_SP;
    }
    else if ([registerName isEqualToString:@"O"])
    {
        return O_O;
    }
    else if ([registerName isEqualToString:@"POP"])
    {
        return O_POP;
    }
    else if ([registerName isEqualToString:@"PEEK"])
    {
        return O_PEEK;
    }
    else if ([registerName isEqualToString:@"PUSH"])
    {
        return O_PUSH;
    }
    else
    {
        @throw @"Invalid register.";
    }
}

@end
