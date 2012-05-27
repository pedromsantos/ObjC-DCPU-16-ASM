#import "Operand.h"

#define OPCODE_WIDTH 4
#define OPERAND_WIDTH 6
#define OPERAND_LITERAL_MAX 0x1F
#define OPERAND_LITERAL_OFFSET 0x20

@interface Statment : NSObject

@property (nonatomic, strong) NSString* label;
@property (nonatomic, strong) NSString* menemonic;
@property (nonatomic, assign) uint8_t opcode;
@property (nonatomic, assign) uint8_t opcodeNonBasic;
@property (nonatomic, strong) Operand* firstOperand;
@property (nonatomic, strong) Operand* secondOperand;

@end
