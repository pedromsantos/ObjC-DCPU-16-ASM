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

#import "Instruction.h"

@implementation Instruction

@synthesize label;
@synthesize opcode;
@synthesize operand1;
@synthesize operand2;

- (enum InstructionInputState)state
{
    return instructionState;
}

- (void)assignLabel:(NSString *)value
{
    self.label = value;
    instructionState = WaitForOpcode;
}

- (void)assignValue:(NSString *)value
{
    switch (instructionState)
    {
        case WaitForOpcodeOrLabel:
        case WaitForOpcode:
            opcode = value;
            instructionState = WaitForOperand1;
            break;
        case WaitForOperand1:
            operand1 = value;
            if ([opcode isEqualToString:@"JSR"])
            {
                instructionState = Complete;
            }
            else
            {
                instructionState = WaitForOperand2;
            }
            break;
        case WaitForOperand2:
            operand2 = value;
            instructionState = Complete;
            break;
        case Complete:
            break;
        default:
            break;
    }
}

- (void)reset
{
    instructionState = WaitForOpcodeOrLabel;
    self.opcode = @"";
    self.operand1 = @"";
    self.operand2 = @"";
    self.label = @"";
}

- (NSArray *)possibleNextInput
{
    NSMutableArray *possibleInputList = [[NSMutableArray alloc] init];

    if (instructionState == WaitForOpcodeOrLabel)
    {
        [possibleInputList addObject:@"Label"];
    }

    if (instructionState == WaitForOpcodeOrLabel || instructionState == WaitForOpcode)
    {
        [possibleInputList addObject:@"JSR"];
        [possibleInputList addObject:@"SET"];
        [possibleInputList addObject:@"SHL"];
        [possibleInputList addObject:@"MOD"];
        [possibleInputList addObject:@"AND"];
        [possibleInputList addObject:@"BOR"];
        [possibleInputList addObject:@"XOR"];
        [possibleInputList addObject:@"SHR"];
        [possibleInputList addObject:@"SHL"];
        [possibleInputList addObject:@"ADD"];
        [possibleInputList addObject:@"SUB"];
        [possibleInputList addObject:@"MUL"];
        [possibleInputList addObject:@"DIV"];
        [possibleInputList addObject:@"IFE"];
        [possibleInputList addObject:@"IFN"];
        [possibleInputList addObject:@"IFG"];
        [possibleInputList addObject:@"IFB"];
    }
    else if (instructionState == WaitForOperand1 || instructionState == WaitForOperand2)
    {
        [possibleInputList addObject:@"PC"];
        [possibleInputList addObject:@"SP"];
        [possibleInputList addObject:@"O"];
        [possibleInputList addObject:@"A"];
        [possibleInputList addObject:@"B"];
        [possibleInputList addObject:@"C"];
        [possibleInputList addObject:@"X"];
        [possibleInputList addObject:@"Y"];
        [possibleInputList addObject:@"Z"];
        [possibleInputList addObject:@"I"];
        [possibleInputList addObject:@"J"];
        [possibleInputList addObject:@"Lit"];
        [possibleInputList addObject:@"Ref"];
        [possibleInputList addObject:@"PUSH"];
        [possibleInputList addObject:@"POP"];
        [possibleInputList addObject:@"PEEK"];
    }

    return possibleInputList;
}

@end
