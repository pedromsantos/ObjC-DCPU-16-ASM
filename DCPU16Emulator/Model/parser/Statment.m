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

#import "Statment.h"

@interface Statment()

@property (nonatomic, strong) NSString* internalMenemonic;

- (void)setOpcodeForMenemonic;

@end

@implementation Statment

@synthesize label;
@synthesize internalMenemonic;
@synthesize opcode;
@synthesize opcodeNonBasic;
@synthesize firstOperand;
@synthesize secondOperand;

- (NSString*)menemonic
{
    return internalMenemonic;
}

- (void)setMenemonic:(NSString *)menemonic
{
    self.internalMenemonic = menemonic;
    [self setOpcodeForMenemonic];
}

- (void)setOpcodeForMenemonic
{
    // basic opcodes
    if ([self.menemonic isEqualToString:@"SET"]) self.opcode = OP_SET;
    else if ([self.menemonic isEqualToString:@"ADD"]) self.opcode = OP_ADD;
    else if ([self.menemonic isEqualToString:@"SUB"]) self.opcode = OP_SUB;
    else if ([self.menemonic isEqualToString:@"MUL"]) self.opcode = OP_MUL;
    else if ([self.menemonic isEqualToString:@"DIV"]) self.opcode = OP_DIV;
    else if ([self.menemonic isEqualToString:@"MOD"]) self.opcode = OP_MOD;
    else if ([self.menemonic isEqualToString:@"SHL"]) self.opcode = OP_SHL;
    else if ([self.menemonic isEqualToString:@"SHR"]) self.opcode = OP_SHR;
    else if ([self.menemonic isEqualToString:@"AND"]) self.opcode = OP_AND;
    else if ([self.menemonic isEqualToString:@"BOR"]) self.opcode = OP_BOR;
    else if ([self.menemonic isEqualToString:@"XOR"]) self.opcode = OP_XOR;
    else if ([self.menemonic isEqualToString:@"IFE"]) self.opcode = OP_IFE;
    else if ([self.menemonic isEqualToString:@"IFN"]) self.opcode = OP_IFN;
    else if ([self.menemonic isEqualToString:@"IFG"]) self.opcode = OP_IFG;
    else if ([self.menemonic isEqualToString:@"IFB"]) self.opcode = OP_IFB;
    
    // non-basic opcodes
    else if ([self.menemonic isEqualToString:@"JSR"])
    {
        self.opcode = 0x0;
        self.opcodeNonBasic = OP_JSR;
    }
    else
    {
        @throw [NSString stringWithFormat:@"No operand for instruction: %@", self.menemonic];
    }
}

@end
