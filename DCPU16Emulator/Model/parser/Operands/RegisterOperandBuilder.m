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

#import "RegisterOperandBuilder.h"
#import "ProgramCounterOperand.h"
#import "StackPointerOperand.h"
#import "RegisterOperand.h"
#import "OverflowOperand.h"
#import "PeekOperand.h"
#import "PushOperand.h"
#import "PopOperand.h"

@implementation RegisterOperandBuilder

- (Operand*)CreateOperandFromMatch:(Match*)match
{
    if ([match.content isEqualToString:@"PC"]) return [[ProgramCounterOperand alloc] init];
    if ([match.content isEqualToString:@"SP"]) return [[StackPointerOperand alloc] init];
    if ([match.content isEqualToString:@"O"]) return [[OverflowOperand alloc] init];
    if ([match.content isEqualToString:@"POP"]) return [[PopOperand alloc] init];
    if ([match.content isEqualToString:@"PEEK"]) return [[PeekOperand alloc] init];
    if ([match.content isEqualToString:@"PUSH"]) return [[PushOperand alloc] init];
    
    return [[RegisterOperand alloc] init];
}

- (void)setRegisterValue:(Match*)match
{
    self.operand.registerValue = [self registerValueForName:match.content];
}

- (int)registerValueForName:(NSString*)name
{
    if ([name isEqualToString:@"A"]) return REG_A;
    else if ([name isEqualToString:@"B"]) return REG_B;
    else if ([name isEqualToString:@"C"]) return REG_C;
    else if ([name isEqualToString:@"X"]) return REG_X;
    else if ([name isEqualToString:@"Y"]) return REG_Y;
    else if ([name isEqualToString:@"Z"]) return REG_Z;
    else if ([name isEqualToString:@"I"]) return REG_I;
    else if ([name isEqualToString:@"J"]) return REG_J;
    else if ([name isEqualToString:@"PC"]) return O_PC;
    else if ([name isEqualToString:@"SP"]) return O_SP;
    else if ([name isEqualToString:@"O"]) return O_O;
    else if ([name isEqualToString:@"POP"]) return O_POP;
    else if ([name isEqualToString:@"PEEK"]) return O_PEEK;
    else if ([name isEqualToString:@"PUSH"]) return O_PUSH;
    else @throw @"Invalid register.";
}

@end
