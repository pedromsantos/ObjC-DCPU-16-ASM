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

#import "Operand.h"

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
    OP_XOR = 0xB,
    OP_IFE = 0xC,
    OP_IFN = 0xD,
    OP_IFG = 0xE,
    OP_IFB = 0xF,
};

typedef enum basic_opcode basicOpcode;

enum non_basic_opcode 
{
    OP_JSR = 0x01,
};

typedef enum non_basic_opcode nonBasicOpcode;

@interface Statment : NSObject

@property (nonatomic, strong) NSString* label;
@property (nonatomic, strong) NSString* menemonic;
@property (nonatomic, assign) basicOpcode opcode;
@property (nonatomic, assign) nonBasicOpcode opcodeNonBasic;
@property (nonatomic, strong) Operand* firstOperand;
@property (nonatomic, strong) Operand* secondOperand;
@property (nonatomic, readonly) NSArray* dat;

- (void) addDat:(UInt16)value;

@end
