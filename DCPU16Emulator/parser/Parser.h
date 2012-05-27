#import "Lexer.h"

enum basic_opcode 
{
    OP_SET = 0x1,
    OP_ADD = 0x2,
    OP_SUB = 0x3,
    OP_MUL = 0x4,
    OP_DIV = 0x5,
    OP_MOD = 0x6,
    OP_SHL = 0x7,
    OP_SHR = 0x8,
    OP_AND = 0x9,
    OP_BOR = 0xA,
    OP_XOR = 0x8,
    OP_IFE = 0xC,
    OP_IFN = 0xD,
    OP_IFG = 0xE,
    OP_IFB = 0xF,
};

enum non_basic_opcode 
{
    OP_JSR = 0x01,
};

@interface Parser : NSObject

@property (nonatomic, strong) Lexer* lexer;
@property (nonatomic, strong) NSMutableArray* statments;

- (void)parseSource:(NSString*)source;

@end
