#import "Operand.h"

@implementation Operand

@synthesize operandType;
@synthesize registerValue;
@synthesize label;
@synthesize nextWord;

- (void)setRegisterValueForName:(NSString*)name
{
    if ([name isEqualToString:@"A"]) registerValue = REG_A;
    else if ([name isEqualToString:@"B"]) registerValue = REG_B;
    else if ([name isEqualToString:@"C"]) registerValue = REG_C;
    else if ([name isEqualToString:@"X"]) registerValue = REG_X;
    else if ([name isEqualToString:@"Y"]) registerValue = REG_Y;
    else if ([name isEqualToString:@"Z"]) registerValue = REG_Z;
    else if ([name isEqualToString:@"I"]) registerValue = REG_I;
    else if ([name isEqualToString:@"J"]) registerValue = REG_J;
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
    
    return O_NW;
}

@end
