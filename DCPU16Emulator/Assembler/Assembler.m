#import "Assembler.h"
#import "Statment.h"
#import "Parser.h"

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
    
    if ([statment.label length] > 0)
    {
        [self.labelDef setObject:[NSNumber numberWithInt:[self.program count]] forKey:[statment.label substringFromIndex:1]];
    }
    else if (statment.opcode == 0)
    {
        if (statment.secondOperand.operandType != O_NULL)
        {
            @throw @"Non-basic opcode must have single operand.";
        }
        
        switch (statment.opcodeNonBasic)
        {
            case OP_JSR:
            {
                opCode = 0;
                opCode |= OP_JSR << OPCODE_WIDTH;
                [self addOpCode:opCode];
                [self assembleOperand:statment.firstOperand forOpCode:opCode withIndex:1];
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
    }
    
    [self addOpCode:opCode];
    
    [self assembleRemainingOperand:statment.firstOperand];
    [self assembleRemainingOperand:statment.secondOperand];
}

- (void)addOpCode:(int)opCode
{
    [program addObject:[NSNumber numberWithInt:opCode]];
}

- (int)assembleOperand:(Operand*)operand forOpCode:(int)opCode withIndex:(int)index
{
    int shift = OPCODE_WIDTH + (index * OPERAND_WIDTH);
    
    switch (operand.operandType) {
        case O_REG:
        case O_INDIRECT_REG:
        {
            opCode |= (operand.operandType + operand.registerValue) << shift;
            break;
        }
        case O_INDIRECT_NW_OFFSET:
        {
            opCode |= (0x10 + operand.registerValue) << shift;
            break;
        }
        case O_NW:
        case O_INDIRECT_NW:
        {
            if ((operand.nextWord <= OPERAND_LITERAL_MAX) && !([operand.label length] > 0))
            {
                opCode |= (operand.nextWord + OPERAND_LITERAL_OFFSET) << shift;
            }
            else
            {
                opCode |= operand.operandType << shift;
            }
            break;
        }
        case O_POP:
        case O_PEEK:
        case O_PUSH:
        case O_SP:
        case O_PC:
        case O_O:
        {
            opCode |= operand.operandType << shift;
            break;
        }
        default:
        {
            break;
        }
    }
    
    return opCode;
}

- (void)assembleRemainingOperand:(Operand*)operand
{
    if(operand.operandType == O_INDIRECT_NW_OFFSET)
    {
        [self addOpCode:operand.nextWord];
    }
    
    if (operand.operandType == O_NW || operand.operandType == O_INDIRECT_NW)
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
            int index = [instruction intValue];
            NSNumber *key = [labelDef objectForKey:label];
            [self.program replaceObjectAtIndex:index withObject:key];
        }
    }
}

@end
