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

#import "Operand.h"
#import "PopOperand.h"
#import "PeekOperand.h"
#import "PushOperand.h"
#import "NullOperand.h"
#import "LiteralOperand.h"
#import "OverflowOperand.h"
#import "NextWordOperand.h"
#import "StackPointerOperand.h"
#import "ProgramCounterOperand.h"
#import "IndirectRegisterOperand.h"
#import "IndirectNextWordOperand.h"
#import "IndirectNextWordOffsetOperand.h"

#define NUM_LITERALS     32

@implementation Operand

@synthesize registerValue;
@synthesize label;
@synthesize nextWord;
@synthesize value;
@synthesize cpuOperations;

- (NSString *)token;
{
    return @"";
}

- (ushort)read
{
    return 0;
}

- (void)writeValue:(ushort)value
{
    @throw @"Not implemented";
}

- (void)process
{

}

- (void)noOp
{

}

- (int)assembleWithShift:(int)shift
{
    return 0;
}

- (int)assembleOperandWithIndex:(int)index
{
    int shift = OPCODE_WIDTH + (index * OPERAND_WIDTH);

    return [self assembleWithShift:shift];
}

+ (enum operand_type)operandTypeForName:(NSString *)name
{
    if ([name length] == 1 && (
                               [name isEqualToString:@"A"] || [name isEqualToString:@"B"] || [name isEqualToString:@"C"] ||
                               [name isEqualToString:@"X"] || [name isEqualToString:@"Y"] || [name isEqualToString:@"Z"] ||
                               [name isEqualToString:@"I"] || [name isEqualToString:@"J"]))
    {
        return O_REG;
    }
    
    if ([name isEqualToString:@"PC"])
    {
        return O_PC;
    }
    if ([name isEqualToString:@"SP"])
    {
        return O_SP;
    }
    if ([name isEqualToString:@"O"])
    {
        return O_O;
    }
    
    if ([name isEqualToString:@"POP"])
    {
        return O_POP;
    }
    if ([name isEqualToString:@"PEEK"])
    {
        return O_PEEK;
    }
    if ([name isEqualToString:@"PUSH"])
    {
        return O_PUSH;
    }
    
    return O_NEXT_WORD;
}

+ (Operand *)newOperand:(enum operand_type)type
{
    switch (type)
    {
        case O_REG:
            return [[RegisterOperand alloc] init];
        case O_INDIRECT_REG:
            return [[IndirectRegisterOperand alloc] init];
        case O_INDIRECT_NEXT_WORD_OFFSET:
            return [[IndirectNextWordOffsetOperand alloc] init];
        case O_POP:
            return [[PopOperand alloc] init];
        case O_PEEK:
            return [[PeekOperand alloc] init];
        case O_PUSH:
            return [[PushOperand alloc] init];
        case O_SP:
            return [[StackPointerOperand alloc] init];
        case O_PC:
            return [[ProgramCounterOperand alloc] init];
        case O_O:
            break;
        case O_INDIRECT_NEXT_WORD:
            return [[IndirectNextWordOperand alloc] init];
        case O_NEXT_WORD:
            return [[NextWordOperand alloc] init];
        case O_LITERAL:
            return [[LiteralOperand alloc] init];
        case O_NULL:
            return [[NullOperand alloc] init];
    }

    return nil;
}

+ (Operand *)newExecutingOperand:(int)code
{
    Operand *operand;

    if (code < O_INDIRECT_REG)
    {
        operand = [[RegisterOperand alloc] init];
        operand.registerValue = (enum operand_register_value) code;
    }
    else if (code < O_INDIRECT_NEXT_WORD_OFFSET)
    {
        operand = [[IndirectNextWordOffsetOperand alloc] init];
        operand.nextWord = (uint16_t) code;
    }
    else if (code < O_POP)
    {
        operand = [[PushOperand alloc] init];
    }
    else if (code == O_POP)
    {
        operand = [[PopOperand alloc] init];
    }
    else if (code == O_PEEK)
    {
        operand = [[PeekOperand alloc] init];
    }
    else if (code == O_PUSH)
    {
        operand = [[PushOperand alloc] init];
    }
    else if (code == O_SP)
    {
        operand = [[StackPointerOperand alloc] init];
    }
    else if (code == O_PC)
    {
        operand = [[ProgramCounterOperand alloc] init];
    }
    else if (code == O_O)
    {
        operand = [[OverflowOperand alloc] init];
    }
    else if (code == O_INDIRECT_NEXT_WORD)
    {
        operand = [[IndirectNextWordOperand alloc] init];
        operand.nextWord = (uint16_t) code;
    }
    else if (code == O_NEXT_WORD)
    {
        operand = [[ProgramCounterOperand alloc] init];
    }
    else
    {
        operand = [[LiteralOperand alloc] init];
        operand.nextWord = (code - O_LITERAL) % NUM_LITERALS;;
    }

    return operand;
}

@end
