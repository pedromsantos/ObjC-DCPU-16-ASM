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
