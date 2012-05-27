#import "Statment.h"

@implementation Statment

@synthesize label;
@synthesize menemonic;
@synthesize opcode;
@synthesize opcodeNonBasic;
@synthesize firstOperand;
@synthesize secondOperand;

- (id)init
{
    self = [super init];
    
    Operand *op1 = [[Operand alloc] init];
    Operand *op2 = [[Operand alloc] init];
    
    firstOperand = op1;
    secondOperand = op2;
    
    return self;
}

@end
