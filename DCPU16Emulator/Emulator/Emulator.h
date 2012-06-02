/*
 * Copyright (C) 2012 Pedro Santos
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

#import "Ram.h"

// Masks to get clear results from an INT.
#define OP_MASK         0xF
#define A_MASK          0x3F
#define B_MASK          0x3F
#define SHORT_MASK      0xFFFF

// Shift width to get clear results from an INT.
#define A_SHIFT         4
#define B_SHIFT         10
#define SHORT_SHIFT     16

@interface Emulator : NSObject
{
    NSString* rp;
}

@property (nonatomic, strong) Ram *ram;

- (id)initWithProgram:(NSArray*)program;
- (BOOL)step;

- (int)getValueForRegister:(int)reg;
- (int)getValueForMemory:(int)address;
- (int)peekInstructionAtProgramCounter;
- (int)getProgramCounter;

@end
