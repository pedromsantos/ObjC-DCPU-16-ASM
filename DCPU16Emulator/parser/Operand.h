
enum operand_type {
    O_REG = 0x00,
    O_INDIRECT_REG = 0x08,
    O_INDIRECT_NW_OFFSET = 0x10,
    O_POP = 0x18,
    O_PEEK = 0x19,
    O_PUSH = 0x1A,
    O_SP = 0x1B,
    O_PC = 0x1C,
    O_O = 0x1D,
    O_INDIRECT_NW = 0x1E,
    O_NW = 0x1F,
    O_LITERAL = 0x20,
    
    O_NULL = 0xDEAD,
};

// General purpose registers.
enum operand_register_value {
    REG_A,
    REG_B,
    REG_C,
    REG_X,
    REG_Y,
    REG_Z,
    REG_I,
    REG_J,
};

// Special registers.
enum operand_special_register {
    SREG_PC,
    SREG_SP,
    SREG_O,
};

@interface Operand : NSObject

@property (nonatomic, assign) enum operand_type operandType;
@property (nonatomic, assign) enum operand_register_value registerValue;
@property (nonatomic, assign) uint16_t nextWord;
@property (nonatomic, strong) NSString* label;

+ (enum operand_type)operandTypeForName:(NSString*)name;

- (void) setRegisterValueForName:(NSString*)name;

@end
