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

#import "Assembler.h"
#import "Statment.h"
#import "NullOperand.h"
#import "NextWordOperand.h"
#import "IndirectNextWordOperand.h"
#import "IndirectNextWordOffsetOperand.h"

@implementation Assembler

@synthesize labelDef;
@synthesize labelRef;
@synthesize program;

- (void)assembleStatments:(NSArray*)statments
{
    self.labelDef = [[NSMutableDictionary alloc] init];
    self.labelRef = [[NSMutableDictionary alloc] init];
    self.program = [[NSMutableArray alloc] init];
    
    for (Statment *statment in statments)
    {
        [self assembleStatment:statment];
    }
    
    [self resolveLabelReferences];
}

- (void)assembleStatment:(Statment*)statment
{
    int opCode = statment.opcode;
    
    [self processLabelInStatment:statment];

    [self processDatInStament:statment];

    if (statment.opcode == 0)
    {
        if (![statment.secondOperand isKindOfClass:[NullOperand class]])
        {
            @throw @"Non-basic opcode must have single operand.";
        }
        
        switch (statment.opcodeNonBasic)
        {
            case OP_JSR:
            {
                opCode = 0;
                opCode |= OP_JSR << OPCODE_WIDTH;
                opCode |= [self assembleOperand:statment.firstOperand forOpCode:0 withIndex:1];
                [self addOpCode:opCode];
                [self assembleOperandNextWord:statment.firstOperand];
                break;
            }
            default:
            {
                @throw @"Unhandled non-basic opcode";
            }
        }
    }
    else 
    {
        opCode = [self assembleOperand:statment.firstOperand forOpCode:opCode withIndex:0];
        opCode = [self assembleOperand:statment.secondOperand forOpCode:opCode withIndex:1];
    
        [self addOpCode:opCode];
    
        [self assembleOperandNextWord:statment.firstOperand];
        [self assembleOperandNextWord:statment.secondOperand];
    }
}

- (void)processLabelInStatment:(Statment *)statment
{
    if ([statment.label length] > 0)
    {
        [self.labelDef setObject:[NSNumber numberWithInt:[program count]] forKey:[statment.label substringFromIndex:1]];
    }
}

- (void)processDatInStament:(Statment *)statment
{
    if ([statment.dat count] != 0)
    {
        for(NSNumber *value in statment.dat)
        {
            [self addOpCode:[value intValue]];
        }
    }
}

- (void)addOpCode:(int)opCode
{
    [program addObject:[NSNumber numberWithInt:opCode]];
}

- (int)assembleOperand:(Operand*)operand forOpCode:(int)opCode withIndex:(int)index
{
    return opCode |= [operand assembleOperandWithIndex:index];
}

- (void)assembleOperandNextWord:(Operand*)operand
{
    if([operand isKindOfClass:[IndirectNextWordOffsetOperand class]])
    {
        [self addOpCode:operand.nextWord];
    }
    
    if ([operand isKindOfClass:[NextWordOperand class]] || [operand isKindOfClass:[IndirectNextWordOperand class]] )
    {
        if([operand.label length] > 0)
        {
            [self.labelRef setObject:operand.label forKey:[NSNumber numberWithInt:[self.program count]]];
            [self addOpCode:0];
        }
        else if(operand.nextWord > OPERAND_LITERAL_MAX)
        {
            [self addOpCode:operand.nextWord];
        }
    }
}

- (void)resolveLabelReferences
{
    for (NSNumber *instruction in labelRef.keyEnumerator)
    {
        NSString* label = [labelRef objectForKey:instruction];
        
        BOOL containsKey = ([labelDef objectForKey:label] != nil);
        
        if(containsKey)
        {
            NSUInteger index = [instruction intValue];
            NSNumber *key = [labelDef objectForKey:label];
            [self.program replaceObjectAtIndex:index withObject:key];
        }
    }
}

@end
