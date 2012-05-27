#import "Operand.h"

@interface Statment : NSObject

@property (nonatomic, strong) NSString* label;
@property (nonatomic, strong) NSString* menemonic;
@property (nonatomic, assign) uint8_t opcode;
@property (nonatomic, assign) uint8_t opcodeNonBasic;
@property (nonatomic, strong) Operand* firstOperand;
@property (nonatomic, strong) Operand* secondOperand;

@end
