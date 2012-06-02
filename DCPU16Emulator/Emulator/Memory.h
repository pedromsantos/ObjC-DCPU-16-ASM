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

// Size variables to define the environment.
#define MEMORY_SIZE     65536
#define NUM_ITERALS     32
#define NUM_REGISTERS   8

// Indices for the RAM
#define PC              @"PC" // program counter
#define SP              @"SP" // stack pointer
#define OV              @"OV" // overflow
#define REG             @"REG" // register
#define LIT             @"LIT" // literals
#define MEM             @"MEM" // memory

typedef int(^memoryOperation)(int, int);
typedef void(^memoryOperationNotification)(NSString*, int);

@interface Memory : NSObject

@property (nonatomic, copy) memoryOperationNotification memoryWillChange;
@property (nonatomic, copy) memoryOperationNotification memoryDidChange;

- (id)init;

- (void)setMemoryValue:(int)value atIndex:(int)index;
- (void)setMemoryValue:(int)value atIndex:(int)index inMemoryArea:(NSString*)area;
- (void)setOverflowRegisterToValue:(int)value;

- (int)getLiteralAtIndex:(int)index;
- (int)getMemoryValueAtIndex:(int)index;
- (int)getValueForRegister:(int)reg;

- (int)getProgramCounter;
- (int)peekInstructionAtProgramCounter;
- (int)readInstructionAtProgramCounter;
- (void)setProgramCounter:(int)value;
- (void)incrementProgramCounter;

- (void)stackPush:(int)value;
- (int)peekInstructionAtStackPointer;
- (int)readInstructionAtStackPointer;
- (int)decrementAndReadInstructionAtStackPointer;

- (void)assignResultOfOperation:(memoryOperation)block 
         usingOperand1AtAddress:(int)address1 
                   inMemoryArea:(NSString*)area1
           andOperand2AtAddress:(int)address2
                   inMemoryArea:(NSString*)area2
                      toAddress:(int)address
                   inMemoryArea:(NSString*)area;

@end
