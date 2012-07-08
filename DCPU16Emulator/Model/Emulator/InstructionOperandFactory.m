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

#import "InstructionOperandFactory.h"
#import "RegisterOperand.h"
#import "IndirectRegisterOperand.h"
#import "IndirectNextWordOffsetOperand.h"
#import "PopOperand.h"
#import "PeekOperand.h"
#import "PushOperand.h"
#import "StackPointerOperand.h"
#import "ProgramCounterOperand.h"
#import "OverflowOperand.h"
#import "IndirectNextWordOperand.h"
#import "NextWordOperand.h"
#import "LiteralOperand.h"
#import "NullOperand.h"

typedef Operand*(^creationStrategy)();

@interface InstructionOperandFactory ()
{
    NSDictionary* operandCreationStrategyMapper;
}

@end

@implementation InstructionOperandFactory

-(id)init
{
    self = [super init];
    
    operandCreationStrategyMapper = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_A],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_B],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_C],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_X],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_Y],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_Z],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_I],
                                     (Operand*)^(){ return [[RegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:REG_J],
                                     (Operand*)^(){ return [[IndirectRegisterOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_INDIRECT_REG],
                                     (Operand*)^(){ return [[IndirectNextWordOffsetOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_INDIRECT_NEXT_WORD_OFFSET],
                                     (Operand*)^(){ return [[PopOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_POP],
                                     (Operand*)^(){ return [[PeekOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_PEEK],
                                     (Operand*)^(){ return [[PushOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_PUSH],
                                     (Operand*)^(){ return [[StackPointerOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_SP],
                                     (Operand*)^(){ return [[ProgramCounterOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_PC],
                                     (Operand*)^(){ return [[OverflowOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_O],
                                     (Operand*)^(){ return [[IndirectNextWordOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_INDIRECT_NEXT_WORD],
                                     (Operand*)^(){ return [[NextWordOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_NEXT_WORD],
                                     (Operand*)^(){ return [[LiteralOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_LITERAL],
                                     (Operand*)^(){ return [[NullOperand alloc] init]; },
                                     [NSNumber numberWithInt:O_NULL],
                                     nil];
    
    return self;
}

- (Operand*)createFromInstructionOperandValue:(ushort)operandValue
{
    creationStrategy creator = [operandCreationStrategyMapper objectForKey:[NSNumber numberWithInt:operandValue]];
    
    Operand *operand = creator();
    operand.value = operandValue;
    
    return operand;
}

@end
